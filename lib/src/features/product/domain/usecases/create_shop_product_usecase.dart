import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/shop_product_entity.dart';
import '../repositories/shop_product_repository.dart';

/// Domain validation runs here (not just in the UI) so no invalid product
/// can be written even by a future non-CMS caller.
class CreateShopProductUseCase
    extends UseCase<ShopProductEntity, ShopProductEntity> {
  final ShopProductRepository _repository;

  CreateShopProductUseCase(this._repository);

  @override
  Future<Either<Failure, ShopProductEntity>> call(ShopProductEntity params) {
    final validation = params.isPublished
        ? ShopProductValidation.forPublish(params)
        : ShopProductValidation.forDraft(params);
    if (!validation.isValid) {
      return Future.value(
        Left(CatalogValidationFailure(validation.errors.values.first)),
      );
    }
    return _repository.createProduct(params);
  }
}
