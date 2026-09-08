import 'package:equatable/equatable.dart';

/// A price add-on nested under a [RepairServiceVariantEntity] — an amount
/// charged on top of the variant's base price for an optional extra (e.g.
/// "Fix trùng 3uTools"). Embedded on the parent `repair_services` document,
/// never its own Firestore collection.
///
/// `price = 0` is a valid, real-world case (a free add-on still worth
/// listing) and must never be treated as "invalid" or "missing".
class RepairServiceAddonEntity extends Equatable {
  final String code;
  final String name;
  final int price;
  final bool enabled;
  final int order;

  const RepairServiceAddonEntity({
    required this.code,
    required this.name,
    required this.price,
    this.enabled = true,
    this.order = 0,
  });

  factory RepairServiceAddonEntity.fromMap(Map<String, dynamic> map) {
    return RepairServiceAddonEntity(
      code: map['code'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      enabled: map['enabled'] as bool? ?? true,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'price': price,
      'enabled': enabled,
      'order': order,
    };
  }

  RepairServiceAddonEntity copyWith({
    String? code,
    String? name,
    int? price,
    bool? enabled,
    int? order,
  }) {
    return RepairServiceAddonEntity(
      code: code ?? this.code,
      name: name ?? this.name,
      price: price ?? this.price,
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [code, name, price, enabled, order];
}
