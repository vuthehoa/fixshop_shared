/// Grading of a used / second-hand commerce product. Free text is never a
/// substitute for this — [ShopProductEntity.conditionNote] carries the
/// extra prose ("Máy đẹp 95%, xước nhẹ viền trái.").
enum ProductCondition {
  likeNew,
  excellent,
  good,
  fair;

  /// Firestore wire value — snake_case, stable across releases.
  String get wireName => switch (this) {
        ProductCondition.likeNew => 'like_new',
        ProductCondition.excellent => 'excellent',
        ProductCondition.good => 'good',
        ProductCondition.fair => 'fair',
      };

  String get displayName => switch (this) {
        ProductCondition.likeNew => 'Như mới',
        ProductCondition.excellent => 'Rất tốt',
        ProductCondition.good => 'Tốt',
        ProductCondition.fair => 'Khá',
      };

  /// Legacy/unknown values fall back to [ProductCondition.good] rather than
  /// throwing — a bad enum string must never break a product read.
  static ProductCondition fromName(String? value) => switch (value) {
        'like_new' => ProductCondition.likeNew,
        'excellent' => ProductCondition.excellent,
        'good' => ProductCondition.good,
        'fair' => ProductCondition.fair,
        _ => ProductCondition.good,
      };
}
