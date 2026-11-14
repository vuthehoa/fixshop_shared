/// Lifecycle of an INTERNAL used-device listing (decision 4, 2026-11-14:
/// products are staff-only — no public shopfront, firestore.rules allow
/// staff read only).
///
/// Wire values are stable strings. Legacy values written before decision 4
/// (`active`, `sold_out`, `hidden`, `archived`) are still parsed so old
/// documents render until `tools/products-status-migration` rewrites them:
///   draft → draft · active → selling · sold_out → sold · sold → sold ·
///   hidden → discontinued · archived → discontinued
enum ProductStatus {
  draft,
  selling,
  reserved,
  sold,
  discontinued;

  String get wireName => name;

  String get displayName => switch (this) {
        ProductStatus.draft => 'Bản nháp',
        ProductStatus.selling => 'Đang bán',
        ProductStatus.reserved => 'Đã giữ hàng',
        ProductStatus.sold => 'Đã bán',
        ProductStatus.discontinued => 'Ngừng bán',
      };

  /// Legacy wire value → new status (same table as the migration script).
  static const Map<String, ProductStatus> legacyMapping = {
    'draft': ProductStatus.draft,
    'active': ProductStatus.selling,
    'sold_out': ProductStatus.sold,
    'soldOut': ProductStatus.sold,
    'sold': ProductStatus.sold,
    'hidden': ProductStatus.discontinued,
    'archived': ProductStatus.discontinued,
  };

  static ProductStatus fromName(String? value) {
    for (final s in ProductStatus.values) {
      if (s.name == value) return s;
    }
    return legacyMapping[value] ?? ProductStatus.draft;
  }

  /// True for a stored value that predates decision 4 (needs migration).
  static bool isLegacyWireValue(String? value) =>
      value != null && !ProductStatus.values.any((s) => s.name == value);

  /// "Archived" in the old UI sense: no longer for sale.
  bool get isArchived => this == ProductStatus.discontinued;

  /// Available to sell at the counter.
  bool get isShoppable => this == ProductStatus.selling;
}

/// Allowed status changes — mirror of firestore.rules `productStatusEdges()`.
/// Same → same is always allowed (plain edits).
abstract final class ProductStatusTransitions {
  static const Map<ProductStatus, Set<ProductStatus>> _next = {
    ProductStatus.draft: {ProductStatus.selling, ProductStatus.discontinued},
    ProductStatus.selling: {
      ProductStatus.draft,
      ProductStatus.reserved,
      ProductStatus.sold,
      ProductStatus.discontinued,
    },
    ProductStatus.reserved: {
      ProductStatus.selling,
      ProductStatus.sold,
      ProductStatus.discontinued,
    },
    // A returned / mis-recorded sale goes back on sale.
    ProductStatus.sold: {ProductStatus.selling},
    ProductStatus.discontinued: {ProductStatus.draft, ProductStatus.selling},
  };

  static Set<ProductStatus> allowedNext(ProductStatus from) =>
      _next[from] ?? const {};

  static bool canTransition(ProductStatus from, ProductStatus to) =>
      from == to || allowedNext(from).contains(to);
}
