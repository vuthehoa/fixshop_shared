import 'catalog_eligibility.dart';

/// Pure, Firestore-free logic for `catalog_model_offers/{modelId}` — the
/// per-MODEL booking summary that Firestore Rules read ONCE to verify every
/// item of a multi-service booking (fixshop_web
/// docs/contracts/MULTI_SERVICE_BOOKING_CONTRACT.md v2):
///
/// ```
/// { modelId, offers: { <serviceId>: { <variantCode>: <int VND > 0> } }, syncedAt, source }
/// ```
///
/// `offers` holds ONLY bookable services/variants — exactly the same predicate
/// as `catalog_eligibility` ([computeEligibilityOffersFromDocument]); a service
/// with no bookable option is omitted. The document is recomputed from ALL
/// services of the model in the same transaction as every `repair_services`
/// write (rules require it), with the model document read inside that
/// transaction as the optimistic lock against concurrent edits.

/// Technical bound of `serviceItems` per booking imposed by the Firestore Rules
/// budget (rules `serviceItemsMax()`, web `SERVICE_ITEMS_TECHNICAL_MAX`). NOT a
/// business limit: customers may select every service a model offers. A model
/// with MORE bookable services than this can still be booked, just not with
/// all of them in one booking — so the CMS warns the admin on save.
const int kServiceItemsTechnicalMax = 20;

/// `offers` for `catalog_model_offers/{modelId}` from the RAW stored
/// `repair_services` documents of that model (`serviceId → data`).
///
/// [overrides] replaces the stored offers of a service that is being written
/// in the same transaction (its new state is not committed yet); an empty map
/// removes it. Documents of another model are ignored.
Map<String, Map<String, int>> computeModelOffers({
  required String modelId,
  required Map<String, Map<String, dynamic>> services,
  Map<String, Map<String, int>> overrides = const {},
}) {
  final out = <String, Map<String, int>>{};
  services.forEach((id, data) {
    if (overrides.containsKey(id)) return;
    if (data['modelId'] != modelId) return;
    final offers = computeEligibilityOffersFromDocument(data);
    if (offers.isNotEmpty) out[id] = offers;
  });
  overrides.forEach((id, offers) {
    if (offers.isNotEmpty) out[id] = Map<String, int>.of(offers);
  });
  return out;
}

/// Result of one `catalog_model_offers/{modelId}` sync, reported to the caller
/// (CMS) after the write committed.
class ModelOffersSyncResult {
  final String modelId;

  /// Number of bookable services of the model after the write.
  final int bookableServices;

  const ModelOffersSyncResult({
    required this.modelId,
    required this.bookableServices,
  });

  /// True when a customer could no longer book ALL services of this model in
  /// one booking (rules bound [kServiceItemsTechnicalMax]).
  bool get exceedsTechnicalMax => bookableServices > kServiceItemsTechnicalMax;

  /// Admin-facing warning (Vietnamese, like the rest of the CMS), or `null`.
  String? get warning => exceedsTechnicalMax
      ? 'Model này có $bookableServices dịch vụ đặt được, vượt giới hạn kỹ thuật '
          '$kServiceItemsTechnicalMax dịch vụ/phiếu của Firestore Rules: khách vẫn '
          'đặt được, nhưng không thể chọn TẤT CẢ dịch vụ trong một phiếu. Báo đội kỹ '
          'thuật nâng giới hạn (hợp đồng MULTI_SERVICE_BOOKING_CONTRACT v2 §3).'
      : null;

  @override
  String toString() =>
      'ModelOffersSyncResult($modelId, bookable=$bookableServices)';
}
