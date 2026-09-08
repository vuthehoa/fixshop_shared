/// Soft-delete status shared by every product-catalog entity.
/// There is no hard delete anywhere in the catalog — "xoá" always means
/// archiving, which is fully reversible via restore.
enum CatalogStatus {
  active,
  archived;

  String get displayName => switch (this) {
        CatalogStatus.active => 'Đang hoạt động',
        CatalogStatus.archived => 'Đã lưu trữ',
      };

  static CatalogStatus fromName(String? value) => switch (value) {
        'active' => CatalogStatus.active,
        'archived' => CatalogStatus.archived,
        _ => CatalogStatus.active,
      };
}
