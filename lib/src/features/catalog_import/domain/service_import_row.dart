import 'package:equatable/equatable.dart';

/// One add-on inside a [VariantImportRow]. `price = 0` is a normal,
/// deliberately-supported value — never treated as missing.
class AddonImportRow extends Equatable {
  final String code;
  final String name;
  final int price;

  const AddonImportRow({
    required this.code,
    required this.name,
    required this.price,
  });

  @override
  List<Object?> get props => [code, name, price];
}

/// One variant inside a [ServiceImportRow].
class VariantImportRow extends Equatable {
  final String code;
  final String name;
  final int price;
  final String? customerDisplayName;
  final List<AddonImportRow> addons;

  const VariantImportRow({
    required this.code,
    required this.name,
    required this.price,
    this.customerDisplayName,
    this.addons = const [],
  });

  @override
  List<Object?> get props => [code, name, price, customerDisplayName, addons];
}

/// One production `repair_services` row to import: a (category, model)
/// pair plus its variants. A source row with a "-" or blank price for a
/// variant simply omits that [VariantImportRow] entirely — see Phase 3
/// spec section 11 — never a null/negative/sentinel price.
class ServiceImportRow extends Equatable {
  final String categoryCode;
  final String modelShorthand;
  final List<VariantImportRow> variants;

  const ServiceImportRow({
    required this.categoryCode,
    required this.modelShorthand,
    required this.variants,
  });

  @override
  List<Object?> get props => [categoryCode, modelShorthand, variants];
}
