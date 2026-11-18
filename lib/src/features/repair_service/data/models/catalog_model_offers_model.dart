import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/services/catalog_eligibility.dart';

/// Firestore payload for `catalog_model_offers/{modelId}` (contract v2):
/// `{ modelId, offers: {serviceId: {variantCode: int VND > 0}}, syncedAt: serverTimestamp, source }`.
///
/// Rules require `modelId == doc id`, `syncedAt == request.time` and — on
/// every `repair_services` write — this document in the SAME batch /
/// transaction (for the old model too when a service changes model).
abstract final class CatalogModelOffersModel {
  static Map<String, dynamic> toFirestore({
    required String modelId,
    required Map<String, Map<String, int>> offers,
    required CatalogEligibilitySource source,
  }) {
    return {
      'modelId': modelId,
      'offers': {
        for (final e in offers.entries) e.key: Map<String, int>.of(e.value),
      },
      'syncedAt': FieldValue.serverTimestamp(),
      'source': source.value,
    };
  }
}
