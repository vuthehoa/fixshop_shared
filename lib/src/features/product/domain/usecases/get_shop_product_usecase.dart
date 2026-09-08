import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/shop_product_entity.dart';
import '../repositories/shop_product_repository.dart';

class GetShopProductUseCase extends UseCase<ShopProductEntity, String> {
  final ShopProductRepository _repository;

  GetShopProductUseCase(this._repository);

  @override
  Future<Either<Failure, ShopProductEntity>> call(String id) =>
      _repository.getProduct(id);
}
