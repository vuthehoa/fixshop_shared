import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_summary.dart';

abstract class DashboardRepository {
  /// Computes the operational dashboard read-model from the existing
  /// `repair_orders`, `customers` and `devices` collections. [createdFrom]/
  /// [createdTo] are optional and, when both provided, additionally
  /// populate [DashboardSummary.newRepairOrdersInRange] — every other field
  /// always reflects current, all-time operational state.
  Future<Either<Failure, DashboardSummary>> getDashboardSummary({
    DateTime? createdFrom,
    DateTime? createdTo,
  });
}
