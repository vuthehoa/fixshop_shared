import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Where a `repair_orders` document originated. Nullable on the entity —
/// legacy documents predate this field and must not be guessed into one
/// bucket or another.
enum RepairOrderSource {
  customerApp,
  cms,
  walkIn;

  static RepairOrderSource? fromName(String? value) => switch (value) {
        'customer_app' => RepairOrderSource.customerApp,
        'cms' => RepairOrderSource.cms,
        'walk_in' => RepairOrderSource.walkIn,
        _ => null,
      };

  String get wireName => switch (this) {
        RepairOrderSource.customerApp => 'customer_app',
        RepairOrderSource.cms => 'cms',
        RepairOrderSource.walkIn => 'walk_in',
      };
}

/// How the customer wants their device handled — matches
/// `fixshop_mobile_app`'s `RepairFulfillmentMethod` exactly (same wire
/// values, `storeDropOff`/`pickup`).
enum RepairFulfillmentMethod {
  storeDropOff,
  pickup;

  static RepairFulfillmentMethod? fromName(String? value) => switch (value) {
        'storeDropOff' => RepairFulfillmentMethod.storeDropOff,
        'pickup' => RepairFulfillmentMethod.pickup,
        _ => null,
      };

  String get wireName => name;
}

/// Contact details captured at booking time — deliberately NOT a profile
/// lookup, so a booking still renders correctly even if the customer later
/// changes their phone/email (Phase 3.1.1 spec section 11).
class BookingContactSnapshot extends Equatable {
  final String name;
  final String phone;
  final String? email;

  const BookingContactSnapshot({
    required this.name,
    required this.phone,
    this.email,
  });

  factory BookingContactSnapshot.fromMap(Map<String, dynamic> map) {
    return BookingContactSnapshot(
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
    };
  }

  @override
  List<Object?> get props => [name, phone, email];
}

/// The device the customer selected/detected at booking time. Deliberately
/// excludes IMEI/MAC/Apple ID/advertising ID — nothing beyond what
/// `fixshop_mobile_app`'s `DetectedDevice` actually captures (Phase 3.1.1
/// spec section 10).
class BookingDeviceSnapshot extends Equatable {
  final String? catalogModelId;
  final String commercialModelName;
  final String brand;
  final String platform;
  final String hardwareIdentifier;
  final String deviceType;
  final String osVersion;

  const BookingDeviceSnapshot({
    this.catalogModelId,
    required this.commercialModelName,
    required this.brand,
    required this.platform,
    required this.hardwareIdentifier,
    required this.deviceType,
    required this.osVersion,
  });

  factory BookingDeviceSnapshot.fromMap(Map<String, dynamic> map) {
    return BookingDeviceSnapshot(
      catalogModelId: map['catalogModelId'] as String?,
      commercialModelName: map['commercialModelName'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      platform: map['platform'] as String? ?? '',
      hardwareIdentifier: map['hardwareIdentifier'] as String? ?? '',
      deviceType: map['deviceType'] as String? ?? '',
      osVersion: map['osVersion'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'catalogModelId': catalogModelId,
      'commercialModelName': commercialModelName,
      'brand': brand,
      'platform': platform,
      'hardwareIdentifier': hardwareIdentifier,
      'deviceType': deviceType,
      'osVersion': osVersion,
    };
  }

  @override
  List<Object?> get props => [
        catalogModelId,
        commercialModelName,
        brand,
        platform,
        hardwareIdentifier,
        deviceType,
        osVersion,
      ];
}

/// One add-on selected at booking time. `price = 0` is a normal, valid
/// value here — never treated as missing (same rule as the catalog's
/// `RepairServiceAddonEntity`).
class BookingAddonSnapshot extends Equatable {
  final String code;
  final String name;
  final int price;

  const BookingAddonSnapshot({
    required this.code,
    required this.name,
    required this.price,
  });

  factory BookingAddonSnapshot.fromMap(Map<String, dynamic> map) {
    return BookingAddonSnapshot(
      code: map['code'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'code': code, 'name': name, 'price': price};
  }

  @override
  List<Object?> get props => [code, name, price];
}

/// The exact service/variant/price the customer booked, frozen at booking
/// time — never re-resolved against the live catalog, so a later price
/// change never retroactively alters what a customer agreed to pay.
class BookingServiceSnapshot extends Equatable {
  final String categoryId;
  final String categoryCode;
  final String categoryName;
  final String serviceId;
  final String variantCode;
  final String variantName;
  final int basePrice;
  final String currency;
  final List<BookingAddonSnapshot> selectedAddons;
  final int estimatedPrice;

  const BookingServiceSnapshot({
    required this.categoryId,
    required this.categoryCode,
    required this.categoryName,
    required this.serviceId,
    required this.variantCode,
    required this.variantName,
    required this.basePrice,
    this.currency = 'VND',
    this.selectedAddons = const [],
    required this.estimatedPrice,
  });

  factory BookingServiceSnapshot.fromMap(Map<String, dynamic> map) {
    return BookingServiceSnapshot(
      categoryId: map['categoryId'] as String? ?? '',
      categoryCode: map['categoryCode'] as String? ?? '',
      categoryName: map['categoryName'] as String? ?? '',
      serviceId: map['serviceId'] as String? ?? '',
      variantCode: map['variantCode'] as String? ?? '',
      variantName: map['variantName'] as String? ?? '',
      basePrice: (map['basePrice'] as num?)?.toInt() ?? 0,
      currency: map['currency'] as String? ?? 'VND',
      selectedAddons: ((map['selectedAddons'] as List<dynamic>?) ?? const [])
          .map((raw) => BookingAddonSnapshot.fromMap(
              Map<String, dynamic>.from(raw as Map)))
          .toList(),
      estimatedPrice: (map['estimatedPrice'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryCode': categoryCode,
      'categoryName': categoryName,
      'serviceId': serviceId,
      'variantCode': variantCode,
      'variantName': variantName,
      'basePrice': basePrice,
      'currency': currency,
      'selectedAddons': selectedAddons.map((a) => a.toMap()).toList(),
      'estimatedPrice': estimatedPrice,
    };
  }

  @override
  List<Object?> get props => [
        categoryId,
        categoryCode,
        categoryName,
        serviceId,
        variantCode,
        variantName,
        basePrice,
        currency,
        selectedAddons,
        estimatedPrice,
      ];
}

/// The appointment slot the customer picked. `date` deserializes a
/// Firestore `Timestamp`; the slot start/end/label are plain display
/// strings, matching `fixshop_mobile_app`'s `AppointmentSlot` exactly.
class BookingAppointmentSnapshot extends Equatable {
  final DateTime date;
  final String slotId;
  final String slotStart;
  final String slotEnd;
  final String slotDisplayLabel;

  const BookingAppointmentSnapshot({
    required this.date,
    required this.slotId,
    required this.slotStart,
    required this.slotEnd,
    required this.slotDisplayLabel,
  });

  factory BookingAppointmentSnapshot.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    return BookingAppointmentSnapshot(
      date: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
      slotId: map['slotId'] as String? ?? '',
      slotStart: map['slotStart'] as String? ?? '',
      slotEnd: map['slotEnd'] as String? ?? '',
      slotDisplayLabel: map['slotDisplayLabel'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'slotId': slotId,
      'slotStart': slotStart,
      'slotEnd': slotEnd,
      'slotDisplayLabel': slotDisplayLabel,
    };
  }

  @override
  List<Object?> get props =>
      [date, slotId, slotStart, slotEnd, slotDisplayLabel];
}

/// One service line of a booking — `repair_orders.serviceItems[i]` from the
/// multi-service contract (`MULTI_SERVICE_BOOKING_CONTRACT.md` §1/§7).
///
/// Parsing is DEFENSIVE (§7): Rules type-check item 0 only, so any label that
/// is not a string reads as `''` and any price that is not a number reads as
/// `0`. [lineTotal] falls back to [basePrice] when absent.
class BookingServiceItem extends Equatable {
  final String serviceId;
  final String categoryId;
  final String serviceName;
  final String variantCode;
  final String variantName;
  final int basePrice;
  final List<BookingAddonSnapshot> selectedAddons;
  final int? warrantyMonths;
  final int lineTotal;

  const BookingServiceItem({
    required this.serviceId,
    required this.categoryId,
    required this.serviceName,
    required this.variantCode,
    required this.variantName,
    required this.basePrice,
    this.selectedAddons = const [],
    this.warrantyMonths,
    required this.lineTotal,
  });

  static String _str(Object? v) => v is String ? v : '';
  static int? _int(Object? v) => v is num ? v.toInt() : null;

  factory BookingServiceItem.fromMap(Map<String, dynamic> map) {
    final base = _int(map['basePrice']) ?? 0;
    final rawAddons = map['selectedAddons'];
    return BookingServiceItem(
      serviceId: _str(map['serviceId']),
      categoryId: _str(map['categoryId']),
      serviceName: _str(map['serviceName']),
      variantCode: _str(map['variantCode']),
      variantName: _str(map['variantName']),
      basePrice: base,
      selectedAddons: rawAddons is List
          ? rawAddons
              .whereType<Map>()
              .map((a) => BookingAddonSnapshot(
                    code: _str(a['code']),
                    name: _str(a['name']),
                    price: _int(a['price']) ?? 0,
                  ))
              .toList()
          : const [],
      warrantyMonths: _int(map['warrantyMonths']),
      lineTotal: _int(map['lineTotal']) ?? base,
    );
  }

  /// The single line a legacy order (no `serviceItems`) is shown as — built
  /// from `serviceSnapshot`, priced at its `estimatedPrice` (old behaviour).
  factory BookingServiceItem.fromSnapshot(BookingServiceSnapshot s) {
    return BookingServiceItem(
      serviceId: s.serviceId,
      categoryId: s.categoryId,
      serviceName: s.categoryName,
      variantCode: s.variantCode,
      variantName: s.variantName,
      basePrice: s.basePrice,
      selectedAddons: s.selectedAddons,
      lineTotal: s.estimatedPrice,
    );
  }

  /// Parses `repair_orders.serviceItems`. Returns `null` when the field is
  /// absent, not a list, or holds no map — the caller then falls back to
  /// `serviceSnapshot` (legacy single-service order). Non-map elements are
  /// skipped; stored order is kept.
  static List<BookingServiceItem>? listFromFirestore(Object? raw) {
    if (raw is! List) return null;
    final items = raw
        .whereType<Map>()
        .map((m) => BookingServiceItem.fromMap(m.cast<String, dynamic>()))
        .toList();
    return items.isEmpty ? null : List.unmodifiable(items);
  }

  int get addonsTotal => selectedAddons.fold(0, (total, a) => total + a.price);

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'categoryId': categoryId,
      'serviceName': serviceName,
      'variantCode': variantCode,
      'variantName': variantName,
      'basePrice': basePrice,
      'selectedAddons': selectedAddons.map((a) => a.toMap()).toList(),
      if (warrantyMonths != null) 'warrantyMonths': warrantyMonths,
      'lineTotal': lineTotal,
    };
  }

  @override
  List<Object?> get props => [
        serviceId,
        categoryId,
        serviceName,
        variantCode,
        variantName,
        basePrice,
        selectedAddons,
        warrantyMonths,
        lineTotal,
      ];
}
