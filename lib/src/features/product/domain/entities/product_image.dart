import 'package:equatable/equatable.dart';

/// One image belonging to a [ShopProductEntity].
///
/// [url] is a Firebase Storage download URL (never a base64 blob, a local
/// path or a temporary object URL). [storagePath] is the object path inside
/// the bucket (`products/{productId}/images/{imageId}.{ext}`) and is what
/// deletes must target so the file is really removed, not just dereferenced.
class ProductImage extends Equatable {
  final String url;
  final String storagePath;
  final int sortOrder;

  const ProductImage({
    required this.url,
    required this.storagePath,
    required this.sortOrder,
  });

  ProductImage copyWith({String? url, String? storagePath, int? sortOrder}) {
    return ProductImage(
      url: url ?? this.url,
      storagePath: storagePath ?? this.storagePath,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [url, storagePath, sortOrder];
}
