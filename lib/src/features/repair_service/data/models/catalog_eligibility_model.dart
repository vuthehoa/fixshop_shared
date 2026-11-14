import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/repair_service_entity.dart';
import '../../domain/services/catalog_eligibility.dart';

/// Firestore payload for `catalog_eligibility/{serviceId}` (contract §2):
/// `{ modelId, offers: {code: int VND > 0}, syncedAt: serverTimestamp, source }`.
///
/// Rules require `syncedAt == request.time`, i.e. it MUST be
/// `FieldValue.serverTimestamp()` and be committed in the same batch /
/// transaction as the `repair_services/{serviceId}` write.
abstract final class CatalogEligibilityModel {
  static Map<String, dynamic> toFirestore({
    required String modelId,
    required Map<String, int> offers,
    required CatalogEligibilitySource source,
  }) {
    return {
      'modelId': modelId,
      'offers': Map<String, int>.of(offers),
      'syncedAt': FieldValue.serverTimestamp(),
      'source': source.value,
    };
  }

  /// Eligibility doc for [service] as it will be stored after the write.
  static Map<String, dynamic> fromService(
    RepairServiceEntity service, {
    required CatalogEligibilitySource source,
  }) {
    return toFirestore(
      modelId: service.modelId,
      offers: service.bookableOffers,
      source: source,
    );
  }
}
