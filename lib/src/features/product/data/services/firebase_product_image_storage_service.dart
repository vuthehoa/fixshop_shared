import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    try {
      final path = _pathFor(productId, imageId, contentType);
      final ref = _storage.ref(path);
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
    } on FirebaseException catch (e) {
      return Left(StorageFailure(_message(e)));
    } catch (e) {
      return Left(StorageFailure('Tải ảnh thất bại: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteByPath(String storagePath) async {
    if (storagePath.trim().isEmpty) return const Right(unit);
    try {
      await _storage.ref(storagePath).delete();
      return const Right(unit);
    } on FirebaseException catch (e) {
      // A missing object is a met goal, not a failure.
      if (e.code == 'object-not-found') return const Right(unit);
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
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return const Right(unit);
      return Left(StorageFailure(_message(e)));
    } catch (e) {
      return Left(StorageFailure('Dọn dẹp ảnh thất bại: $e'));
    }
  }

  String _message(FirebaseException e) {
    return switch (e.code) {
      'unauthorized' =>
        'Bạn không có quyền tải ảnh lên. Vui lòng đăng nhập lại.',
      'canceled' => 'Quá trình tải ảnh đã bị huỷ.',
      'retry-limit-exceeded' =>
        'Tải ảnh quá thời gian cho phép. Kiểm tra kết nối và thử lại.',
      _ => e.message ?? 'Lỗi lưu trữ ảnh (${e.code}).',
    };
  }
}
