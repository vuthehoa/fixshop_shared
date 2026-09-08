import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardSummaryUseCase
    extends UseCase<DashboardSummary, GetDashboardSummaryParams> {
  final DashboardRepository _repository;

  GetDashboardSummaryUseCase(this._repository);

  @override
  Future<Either<Failure, DashboardSummary>> call(
      GetDashboardSummaryParams params) {
    return _repository.getDashboardSummary(
      createdFrom: params.createdFrom,
      createdTo: params.createdTo,
    );
  }
}

class GetDashboardSummaryParams extends Equatable {
  final DateTime? createdFrom;
  final DateTime? createdTo;

  const GetDashboardSummaryParams({this.createdFrom, this.createdTo});

  @override
  List<Object?> get props => [createdFrom, createdTo];
}
