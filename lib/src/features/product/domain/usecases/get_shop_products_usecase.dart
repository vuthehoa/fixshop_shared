import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/shop_product_entity.dart';
import '../repositories/shop_product_repository.dart';
import '../value_objects/shop_product_filter.dart';

class GetShopProductsUseCase
    extends UseCase<PaginatedResult<ShopProductEntity>, GetShopProductsParams> {
  final ShopProductRepository _repository;

  GetShopProductsUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<ShopProductEntity>>> call(
    GetShopProductsParams params,
  ) {
    return _repository.getProducts(params.filter,
        startAfter: params.startAfter);
  }
}

class GetShopProductsParams extends Equatable {
  final ShopProductFilter filter;
  final DocumentSnapshot? startAfter;

  const GetShopProductsParams({required this.filter, this.startAfter});

  @override
  List<Object?> get props => [filter, startAfter];
}
