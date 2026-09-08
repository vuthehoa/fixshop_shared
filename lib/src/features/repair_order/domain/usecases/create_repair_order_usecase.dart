import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/repair_order_entity.dart';
import '../repositories/repair_order_repository.dart';

/// Unlike Manufacturer/Customer/Device's create use cases, this one needs
/// the actor (not just the draft entity) — the very first timeline entry
/// ("Created") must be stamped with who created it, and a repair order's
/// embedded timeline has no other channel for that information.
class CreateRepairOrderUseCase
    extends UseCase<RepairOrderEntity, CreateRepairOrderParams> {
  final RepairOrderRepository _repository;

  CreateRepairOrderUseCase(this._repository);

  @override
  Future<Either<Failure, RepairOrderEntity>> call(
      CreateRepairOrderParams params) {
    return _repository.createRepairOrder(
      params.draft.copyWith(createdBy: params.actor.id),
      actor: params.actor,
    );
  }
}

class CreateRepairOrderParams extends Equatable {
  final RepairOrderEntity draft;
  final UserEntity actor;

  const CreateRepairOrderParams({required this.draft, required this.actor});

  @override
  List<Object?> get props => [draft, actor];
}
