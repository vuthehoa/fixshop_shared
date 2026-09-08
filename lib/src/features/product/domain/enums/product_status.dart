/// Lifecycle status of a commerce product ("sản phẩm cũ" listing).
///
/// This is deliberately distinct from `CatalogStatus` (master catalog) —
/// a listing has a richer lifecycle than active/archived. `archived` still
/// plays the same soft-delete role every other module uses: never removed
/// from Firestore, only hidden from the shopfront and the active list.
enum ProductStatus {
  draft,
  active,
  soldOut,
  sold,
  hidden,
  archived;

  String get wireName => switch (this) {
        ProductStatus.draft => 'draft',
        ProductStatus.active => 'active',
        ProductStatus.soldOut => 'sold_out',
        ProductStatus.sold => 'sold',
        ProductStatus.hidden => 'hidden',
        ProductStatus.archived => 'archived',
      };

  String get displayName => switch (this) {
        ProductStatus.draft => 'Bản nháp',
        ProductStatus.active => 'Đang bán',
        ProductStatus.soldOut => 'Hết hàng',
        ProductStatus.sold => 'Đã bán',
        ProductStatus.hidden => 'Đã ẩn',
        ProductStatus.archived => 'Đã lưu trữ',
      };

  static ProductStatus fromName(String? value) => switch (value) {
        'draft' => ProductStatus.draft,
        'active' => ProductStatus.active,
        'sold_out' => ProductStatus.soldOut,
        'sold' => ProductStatus.sold,
        'hidden' => ProductStatus.hidden,
        'archived' => ProductStatus.archived,
        _ => ProductStatus.draft,
      };

  bool get isArchived => this == ProductStatus.archived;

  /// Visible on the mobile shopfront only in this state (combined with
  /// `isPublished == true` and `quantity > 0`).
  bool get isShoppable => this == ProductStatus.active;
}
