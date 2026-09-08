import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_image.dart';

/// Uploads/deletes commerce-product images in Firebase Storage under
/// `products/{productId}/images/{imageId}.{ext}`.
///
/// The CMS wizard generates the `productId` up front, uploads every image,
/// collects the download URLs, and only then writes the Firestore document
/// — so a failed upload never leaves a half-created product, and an
/// abandoned wizard leaves at most orphan files under a never-referenced id
/// (which [deleteFolder] cleans up).
abstract class ProductImageStorageService {
  /// Uploads one image and returns a [ProductImage] carrying its download
  /// url + object path. [sortOrder] is passed straight through onto the
  /// result. [contentType] must be one of image/jpeg, image/png, image/webp.
  Future<Either<Failure, ProductImage>> uploadImage({
    required String productId,
    required String imageId,
    required Uint8List bytes,
    required String contentType,
    required int sortOrder,
  });

  /// Deletes a single object by its storage path. Missing objects resolve
  /// to [Right] (idempotent) — a delete that finds nothing already met its
  /// goal.
  Future<Either<Failure, Unit>> deleteByPath(String storagePath);

  /// Deletes every object under `products/{productId}/images/`. Used to
  /// clean up after a hard product delete or an aborted create.
  Future<Either<Failure, Unit>> deleteProductFolder(String productId);
}

/// Client-side image constraints. Shared so the CMS validates before upload
/// and any future Storage-rules generator can reuse the same numbers.
abstract final class ProductImageConstraints {
  static const int maxImages = 10;
  static const int maxBytesPerImage = 8 * 1024 * 1024; // 8 MB
  static const Set<String> allowedContentTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
  };
  static const Set<String> allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  static String extensionForContentType(String contentType) =>
      switch (contentType) {
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
        'image/webp' => 'webp',
        _ => 'jpg',
      };

  /// `null` when acceptable, otherwise a user-facing Vietnamese message.
  static String? validate({
    required String contentType,
    required int byteLength,
    required int currentImageCount,
  }) {
    if (!allowedContentTypes.contains(contentType)) {
      return 'Định dạng ảnh không hỗ trợ. Chỉ chấp nhận JPG, PNG hoặc WEBP.';
    }
    if (byteLength > maxBytesPerImage) {
      return 'Ảnh vượt quá dung lượng tối đa ${maxBytesPerImage ~/ (1024 * 1024)}MB.';
    }
    if (currentImageCount >= maxImages) {
      return 'Chỉ được tải lên tối đa $maxImages ảnh.';
    }
    return null;
  }
}
