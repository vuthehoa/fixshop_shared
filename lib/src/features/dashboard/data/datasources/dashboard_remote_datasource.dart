import '../../domain/entities/dashboard_summary.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummary> getDashboardSummary({
    DateTime? createdFrom,
    DateTime? createdTo,
  });
}
