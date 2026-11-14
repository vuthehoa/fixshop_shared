import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../enums/product_status.dart';
import '../repositories/shop_product_repository.dart';

class SetShopProductPublishedUseCase
    extends UseCase<void, SetShopProductPublishedParams> {
  final ShopProductRepository _repository;

  SetShopProductPublishedUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(SetShopProductPublishedParams params) {
    return _repository.setPublished(
      params.id,
      isPublished: params.isPublished,
      actorId: params.actorId,
    );
  }
}

class SetShopProductPublishedParams extends Equatable {
  final String id;
  final bool isPublished;
  final String actorId;

  const SetShopProductPublishedParams({
    required this.id,
    required this.isPublished,
    required this.actorId,
  });

  @override
  List<Object?> get props => [id, isPublished, actorId];
}

/// Decision 4 — generic status change (Bản nháp / Đang bán / Đã giữ hàng /
/// Đã bán / Ngừng bán) along [ProductStatusTransitions].
class ChangeShopProductStatusUseCase
    extends UseCase<void, ChangeShopProductStatusParams> {
  final ShopProductRepository _repository;

  ChangeShopProductStatusUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ChangeShopProductStatusParams params) =>
      _repository.changeStatus(
        params.id,
        to: params.to,
        actorId: params.actorId,
      );
}

class ChangeShopProductStatusParams extends Equatable {
  final String id;
  final ProductStatus to;
  final String actorId;

  const ChangeShopProductStatusParams({
    required this.id,
    required this.to,
    required this.actorId,
  });

  @override
  List<Object?> get props => [id, to, actorId];
}
