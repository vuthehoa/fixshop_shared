import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/shop_product_repository.dart';

class ArchiveShopProductUseCase extends UseCase<void, ShopProductActorParams> {
  final ShopProductRepository _repository;

  ArchiveShopProductUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ShopProductActorParams params) =>
      _repository.archiveProduct(params.id, actorId: params.actorId);
}

class RestoreShopProductUseCase extends UseCase<void, ShopProductActorParams> {
  final ShopProductRepository _repository;

  RestoreShopProductUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ShopProductActorParams params) =>
      _repository.restoreProduct(params.id, actorId: params.actorId);
}

class DeleteShopProductUseCase extends UseCase<void, String> {
  final ShopProductRepository _repository;

  DeleteShopProductUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String id) =>
      _repository.deleteProduct(id);
}

class ShopProductActorParams extends Equatable {
  final String id;
  final String actorId;

  const ShopProductActorParams({required this.id, required this.actorId});

  @override
  List<Object?> get props => [id, actorId];
}
