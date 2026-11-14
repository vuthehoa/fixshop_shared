import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/product_image.dart';
import '../../domain/repositories/product_image_storage_service.dart';

/// Firebase Storage implementation.
///
/// Object layout: `products/{productId}/images/{imageId}.{ext}` — exactly
/// what `storage.rules` grants CMS-staff write and public read on.
class FirebaseProductImageStorageService implements ProductImageStorageService {
  final FirebaseStorage _storage;

  FirebaseProductImageStorageService({required FirebaseStorage storage})
      : _storage = storage;

  String _pathFor(String productId, String imageId, String contentType) {
    final ext = ProductImageConstraints.extensionForContentType(contentType);
    return 'products/$productId/images/$imageId.$ext';
  }

  @override
  Future<Either<Failure, ProductImage>> uploadImage({
    required String productId,
    required String imageId,
    required Uint8List bytes,
    required String contentType,
    required int sortOrder,
  }) async {
    if (!ProductImageConstraints.allowedContentTypes.contains(contentType)) {
      return const Left(
        StorageFailure('Định dạng ảnh không hỗ trợ (chỉ JPG, PNG, WEBP).'),
      );
    }
    if (bytes.lengthInBytes > ProductImageConstraints.maxBytesPerImage) {
      return const Left(StorageFailure('Ảnh vượt quá dung lượng cho phép.'));
    }
    final path = _pathFor(productId, imageId, contentType);
    try {
      final ref = _storage.ref(path);
      if (kDebugMode) {
        final user = FirebaseAuth.instance.currentUser;
        debugPrint(
          '[ProductStorage] upload path=${ref.fullPath} '
          'bucket=${_storage.bucket} '
          'authUid=${user?.uid} contentType=$contentType '
          'bytes=${bytes.lengthInBytes}',
        );
      }
      await ref.putData(
        bytes,
        SettableMetadata(
          contentType: contentType,
          cacheControl: 'public, max-age=31536000, immutable',
        ),
      );
      final url = await ref.getDownloadURL();
      return Right(
        ProductImage(url: url, storagePath: path, sortOrder: sortOrder),
      );
    } on FirebaseException catch (e, st) {
      _logFirebaseException('upload', path, e, st);
      return Left(StorageFailure(_message(e)));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint(
            '[ProductStorage] upload path=$path unexpected error: $e\n$st');
      }
      return Left(StorageFailure('Tải ảnh thất bại: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteByPath(String storagePath) async {
    if (storagePath.trim().isEmpty) return const Right(unit);
    try {
      await _storage.ref(storagePath).delete();
      return const Right(unit);
    } on FirebaseException catch (e, st) {
      // A missing object is a met goal, not a failure.
      if (e.code == 'object-not-found') return const Right(unit);
      _logFirebaseException('delete', storagePath, e, st);
      return Left(StorageFailure(_message(e)));
    } catch (e) {
      return Left(StorageFailure('Xoá ảnh thất bại: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProductFolder(String productId) async {
    try {
      final folder = _storage.ref('products/$productId/images');
      final listing = await folder.listAll();
      await Future.wait(listing.items.map((item) => item.delete()));
      return const Right(unit);
    } on FirebaseException catch (e, st) {
      if (e.code == 'object-not-found') return const Right(unit);
      _logFirebaseException(
          'deleteFolder', 'products/$productId/images', e, st);
      return Left(StorageFailure(_message(e)));
    } catch (e) {
      return Left(StorageFailure('Dọn dẹp ảnh thất bại: $e'));
    }
  }

  /// Developer diagnostics — never shown to the end user. The raw Storage
  /// `code`/`plugin` is what distinguishes "security rules not deployed / path
  /// not granted" (`unauthorized` while the ID token is perfectly valid) from
  /// a genuine auth problem. Mirrors `ShopProductRepositoryImpl`'s handler.
  void _logFirebaseException(
    String op,
    String path,
    FirebaseException e,
    StackTrace st,
  ) {
    if (!kDebugMode) return;
    final user = FirebaseAuth.instance.currentUser;
    debugPrint(
      '[ProductStorage] $op FAILED path=$path '
      'code=${e.code} plugin=${e.plugin} message=${e.message} '
      'authUid=${user?.uid} signedIn=${user != null}\n$st',
    );
  }

  String _message(FirebaseException e) {
    return switch (e.code) {
      // The caller IS authenticated (a valid ID token was sent) but Storage
      // Rules rejected the object path — a rules/config problem, not a stale
      // session. Telling the user to "log in again" would send them in circles.
      'unauthorized' => 'Không thể tải ảnh lên do cấu hình quyền lưu trữ. '
          'Vui lòng thử lại hoặc liên hệ quản trị viên.',
      'unauthenticated' =>
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      'canceled' => 'Quá trình tải ảnh đã bị huỷ.',
      'retry-limit-exceeded' =>
        'Tải ảnh quá thời gian cho phép. Kiểm tra kết nối và thử lại.',
      'quota-exceeded' =>
        'Bộ nhớ lưu trữ đã đầy. Vui lòng liên hệ quản trị viên.',
      _ => e.message ?? 'Lỗi lưu trữ ảnh (${e.code}).',
    };
  }
}
