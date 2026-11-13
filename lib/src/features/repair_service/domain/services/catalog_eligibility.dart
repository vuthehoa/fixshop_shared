import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../entities/repair_service_entity.dart';
import '../entities/repair_service_variant_entity.dart';

/// Pure, Firestore-free logic for the `catalog_eligibility/{serviceId}`
/// contract (fixshop_web docs/catalog/ELIGIBILITY_CONTRACT.md §1–2).
///
/// `catalog_eligibility` is the minimal booking summary Firestore Rules
/// compare a booking against: `offers[variantCode] == serviceSnapshot.basePrice`.
/// It is written in the SAME batch/transaction as every `repair_services`
/// write (rules reject a service write without it), so the summary can
/// never drift from the service document.
///
/// Price semantics (contract §1): a variant price is valid only when it is
/// an INTEGER number of VND strictly greater than 0 and the currency is
/// `VND` or empty. `0` / empty / negative / fractional = "chưa có giá"
/// (no price yet) — never "miễn phí". Add-on prices are NOT covered by this
/// contract (a 0-priced add-on is still a legitimate free add-on).

/// Who wrote a `catalog_eligibility` document (`source` field).
enum CatalogEligibilitySource {
  cms('cms'),
  importer('import'),
  migration('migration');

  /// Wire value stored in Firestore.
  final String value;

  const CatalogEligibilitySource(this.value);
}

/// True when [price] is a valid bookable VND price: an integer > 0.
///
/// Accepts `Object?` so raw Firestore values (which may be `double`, `String`
/// or `null`) are judged exactly like the contract says — a `double` is
/// accepted only when it has no fractional part (on Flutter web every number
/// is a JS double, so `810000.0` and `810000` are the same value there).
bool isValidOfferPrice(Object? price) {
  if (price is int) return price > 0;
  if (price is double) {
    return price.isFinite && price == price.truncateToDouble() && price > 0;
  }
  return false;
}

/// True when [currency] is acceptable for an offer (`VND` or empty/missing).
bool isValidOfferCurrency(Object? currency) {
  if (currency == null) return true;
  if (currency is! String) return false;
  final c = currency.trim();
  return c.isEmpty || c == 'VND';
}

/// True when this variant can be offered for booking on its own
/// (enabled, non-empty code, valid integer price > 0, VND/empty currency).
/// Does NOT look at the parent service's status/enabled flag.
bool isBookableVariant(RepairServiceVariantEntity variant) {
  return variant.enabled &&
      variant.code.trim().isNotEmpty &&
      isValidOfferPrice(variant.price) &&
      isValidOfferCurrency(variant.currency);
}

/// Computes `catalog_eligibility.offers` per contract §2:
/// if the service is `active` AND `enabled`, every variant that is
/// [isBookableVariant] contributes `offers[code] = price`; otherwise `{}`.
///
/// When two enabled variants share a code (which validation forbids) the
/// FIRST one wins, deterministically.
Map<String, int> computeEligibilityOffers({
  required CatalogStatus status,
  required bool enabled,
  required Iterable<RepairServiceVariantEntity> variants,
}) {
  final offers = <String, int>{};
  if (status != CatalogStatus.active || !enabled) return offers;
  for (final v in variants) {
    if (!isBookableVariant(v)) continue;
    offers.putIfAbsent(v.code.trim(), () => v.price);
  }
  return offers;
}

/// Same as [computeEligibilityOffers] but over a RAW `repair_services`
/// document map (as stored in Firestore), so tools that never build an
/// entity — or documents carrying a fractional/string price — are judged by
/// the exact contract rules instead of the entity's lossy `toInt()` parse.
///
/// Missing `enabled` / variant `enabled` default to `true` (legacy docs,
/// same default as the entity parser); missing `status` is NOT active.
Map<String, int> computeEligibilityOffersFromDocument(
  Map<String, dynamic> data,
) {
  final offers = <String, int>{};
  if (data['status'] != CatalogStatus.active.name) return offers;
  if ((data['enabled'] ?? true) != true) return offers;
  final rawVariants = data['variants'];
  if (rawVariants is! List) return offers;
  for (final raw in rawVariants) {
    if (raw is! Map) continue;
    if ((raw['enabled'] ?? true) != true) continue;
    final code = raw['code'];
    if (code is! String || code.trim().isEmpty) continue;
    final price = raw['price'];
    if (!isValidOfferPrice(price)) continue;
    if (!isValidOfferCurrency(raw['currency'])) continue;
    offers.putIfAbsent(code.trim(), () => (price as num).toInt());
  }
  return offers;
}

/// Computed, display-only booking state of a service (contract §1).
/// NOT stored anywhere — derived from `status`, `enabled` and the variants.
enum RepairServiceBookability {
  /// active + enabled + ≥1 bookable option → "Đặt lịch được".
  bookable('Đặt lịch được'),

  /// active + enabled but no option with a valid price → "Chưa có giá hợp lệ".
  noValidPrice('Chưa có giá hợp lệ'),

  /// active but `enabled == false` → "Tạm ngưng nhận đặt lịch".
  bookingPaused('Tạm ngưng nhận đặt lịch'),

  /// `status == archived` → "Đang ẩn".
  hidden('Đang ẩn');

  final String label;

  const RepairServiceBookability(this.label);
}

/// See [RepairServiceBookability]. Hidden wins over paused wins over price.
RepairServiceBookability computeBookability({
  required CatalogStatus status,
  required bool enabled,
  required Iterable<RepairServiceVariantEntity> variants,
}) {
  if (status != CatalogStatus.active) return RepairServiceBookability.hidden;
  if (!enabled) return RepairServiceBookability.bookingPaused;
  final hasOffer = computeEligibilityOffers(
    status: status,
    enabled: enabled,
    variants: variants,
  ).isNotEmpty;
  return hasOffer
      ? RepairServiceBookability.bookable
      : RepairServiceBookability.noValidPrice;
}

// ─────────────────────────────────────────────────────────────────────────────
// Price audit (activity_logs metadata)
// ─────────────────────────────────────────────────────────────────────────────

final RegExp _codeWarrantyPattern =
    RegExp(r'_bh(\d{1,3})(?=$|_)', caseSensitive: false);
final RegExp _nameWarrantyPattern = RegExp(
  r'(?:\bBH|bảo\s*hành)\s*(\d{1,3})\s*tháng',
  caseSensitive: false,
  unicode: true,
);

/// Warranty months encoded in a variant: a `_bhN` code segment (e.g.
/// `screen_zin_bh12`) or "BH N tháng" / "Bảo hành N tháng" in the name.
/// The code wins when both are present. `null` when neither matches.
int? parseWarrantyMonths({required String code, required String name}) {
  final fromCode = _codeWarrantyPattern.firstMatch(code);
  if (fromCode != null) return int.parse(fromCode.group(1)!);
  final fromName = _nameWarrantyPattern.firstMatch(name);
  if (fromName != null) return int.parse(fromName.group(1)!);
  return null;
}

/// One variant's price/enabled change between two versions of a service.
/// `old*` is `null` when the variant was added, `new*` when it was removed.
class VariantPricingChange {
  final String variantCode;
  final String variantName;
  final int? warrantyMonths;
  final int? oldPrice;
  final int? newPrice;
  final bool? oldEnabled;
  final bool? newEnabled;

  const VariantPricingChange({
    required this.variantCode,
    required this.variantName,
    required this.warrantyMonths,
    required this.oldPrice,
    required this.newPrice,
    required this.oldEnabled,
    required this.newEnabled,
  });

  Map<String, dynamic> toMap() => {
        'variantCode': variantCode,
        'variantName': variantName,
        'warrantyMonths': warrantyMonths,
        'oldPrice': oldPrice,
        'newPrice': newPrice,
        'oldEnabled': oldEnabled,
        'newEnabled': newEnabled,
      };

  @override
  String toString() => 'VariantPricingChange(${toMap()})';
}

/// Every variant (matched by code) whose price or enabled flag differs
/// between [before] and [after], including added and removed variants.
/// Order: [after]'s order first, then removed variants in [before]'s order.
List<VariantPricingChange> diffVariantPricing(
  Iterable<RepairServiceVariantEntity> before,
  Iterable<RepairServiceVariantEntity> after,
) {
  final oldByCode = <String, RepairServiceVariantEntity>{};
  for (final v in before) {
    oldByCode.putIfAbsent(v.code, () => v);
  }
  final seen = <String>{};
  final changes = <VariantPricingChange>[];

  for (final n in after) {
    if (!seen.add(n.code)) continue;
    final o = oldByCode[n.code];
    if (o != null && o.price == n.price && o.enabled == n.enabled) continue;
    changes.add(VariantPricingChange(
      variantCode: n.code,
      variantName: n.name,
      warrantyMonths: parseWarrantyMonths(code: n.code, name: n.name),
      oldPrice: o?.price,
      newPrice: n.price,
      oldEnabled: o?.enabled,
      newEnabled: n.enabled,
    ));
  }
  for (final o in oldByCode.values) {
    if (seen.contains(o.code)) continue;
    changes.add(VariantPricingChange(
      variantCode: o.code,
      variantName: o.name,
      warrantyMonths: parseWarrantyMonths(code: o.code, name: o.name),
      oldPrice: o.price,
      newPrice: null,
      oldEnabled: o.enabled,
      newEnabled: null,
    ));
  }
  return changes;
}

/// `activity_logs.metadata` for an `UPDATE_REPAIR_SERVICE_PRICING` entry, or
/// `null` when nothing price/enabled-related changed between [before] and
/// [after] (variant price/enabled, added/removed variants, or the
/// service-level `enabled` flag). Name/description-only edits are not
/// pricing changes and produce no audit row.
Map<String, dynamic>? buildPricingAuditMetadata({
  required RepairServiceEntity before,
  required RepairServiceEntity after,
}) {
  final changes = diffVariantPricing(before.variants, after.variants);
  final serviceEnabledChanged = before.enabled != after.enabled;
  if (changes.isEmpty && !serviceEnabledChanged) return null;
  return {
    'serviceId': after.id,
    'modelId': after.modelId,
    'categoryId': after.categoryId,
    'oldServiceEnabled': before.enabled,
    'newServiceEnabled': after.enabled,
    'changes': changes.map((c) => c.toMap()).toList(),
  };
}
