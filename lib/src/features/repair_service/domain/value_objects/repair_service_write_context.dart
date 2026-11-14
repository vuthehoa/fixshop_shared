import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../services/catalog_eligibility.dart';

/// Who is writing a `repair_services` document and from where.
///
/// - [source] is stamped on the same-batch `catalog_eligibility` doc.
/// - When [actorId] AND [actorRole] are both known, an update that changes
///   any variant price/enabled flag (or the service-level `enabled` flag)
///   also writes an `UPDATE_REPAIR_SERVICE_PRICING` activity log in the SAME
///   transaction, so a price change can never land without its audit row.
class RepairServiceWriteContext extends Equatable {
  final CatalogEligibilitySource source;
  final String? actorId;
  final UserRole? actorRole;

  const RepairServiceWriteContext({
    this.source = CatalogEligibilitySource.cms,
    this.actorId,
    this.actorRole,
  });

  bool get canAudit =>
      actorId != null && actorId!.isNotEmpty && actorRole != null;

  @override
  List<Object?> get props => [source, actorId, actorRole];
}
