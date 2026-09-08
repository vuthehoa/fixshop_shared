import 'package:equatable/equatable.dart';

import 'repair_service_addon_entity.dart';

/// A price tier nested under a [RepairServiceEntity] (e.g. "Pin Pisen" vs.
/// "Pin có cổ" under "Pin iPhone 15 Pro Max"). Embedded on the parent
/// `repair_services` document, never its own Firestore collection.
///
/// Deliberately NOT the same concept as the pre-existing top-level
/// `variants` collection / `VariantEntity`, which represents a *device*
/// variant (storage/color) and has nothing to do with service pricing —
/// reusing that collection here would corrupt an unrelated, already-live
/// concept (see Phase 1 audit).
///
/// `price = 0` is a valid, real-world case and must never be treated as
/// "invalid" or "missing" — only the entry's *absence* from [addons] means
/// "not applicable".
class RepairServiceVariantEntity extends Equatable {
  final String code;
  final String name;
  final String? customerDisplayName;
  final int price;
  final String currency;
  final bool enabled;
  final int order;
  final List<RepairServiceAddonEntity> addons;

  const RepairServiceVariantEntity({
    required this.code,
    required this.name,
    this.customerDisplayName,
    required this.price,
    this.currency = 'VND',
    this.enabled = true,
    this.order = 0,
    this.addons = const [],
  });

  factory RepairServiceVariantEntity.fromMap(Map<String, dynamic> map) {
    return RepairServiceVariantEntity(
      code: map['code'] as String? ?? '',
      name: map['name'] as String? ?? '',
      customerDisplayName: map['customerDisplayName'] as String?,
      price: (map['price'] as num?)?.toInt() ?? 0,
      currency: map['currency'] as String? ?? 'VND',
      enabled: map['enabled'] as bool? ?? true,
      order: (map['order'] as num?)?.toInt() ?? 0,
      addons: ((map['addons'] as List<dynamic>?) ?? const [])
          .map((raw) => RepairServiceAddonEntity.fromMap(
                Map<String, dynamic>.from(raw as Map),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'customerDisplayName': customerDisplayName,
      'price': price,
      'currency': currency,
      'enabled': enabled,
      'order': order,
      'addons': addons.map((a) => a.toMap()).toList(),
    };
  }

  List<RepairServiceAddonEntity> get activeAddons =>
      addons.where((a) => a.enabled).toList();

  RepairServiceVariantEntity copyWith({
    String? code,
    String? name,
    String? customerDisplayName,
    int? price,
    String? currency,
    bool? enabled,
    int? order,
    List<RepairServiceAddonEntity>? addons,
  }) {
    return RepairServiceVariantEntity(
      code: code ?? this.code,
      name: name ?? this.name,
      customerDisplayName: customerDisplayName ?? this.customerDisplayName,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
      addons: addons ?? this.addons,
    );
  }

  @override
  List<Object?> get props => [
        code,
        name,
        customerDisplayName,
        price,
        currency,
        enabled,
        order,
        addons,
      ];
}
