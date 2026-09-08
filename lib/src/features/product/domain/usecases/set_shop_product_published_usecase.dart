import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
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
