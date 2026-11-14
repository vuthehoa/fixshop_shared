import '../../auth/domain/entities/user_entity.dart';

/// Decision 2b (2026-11-14): warranty activation runs in the CMS as a client
/// transaction — no Cloud Functions. This file is the Dart port of the former
/// `functions/src/warranty/activation.ts` business logic; `firestore.rules`
/// (fixshop_cms, `isValidWarrantyActivation` / `isWarrantyVoidOrExtend`) is
/// the enforcement and must stay in sync with it.
abstract final class DeviceWarrantyActivation {
  static const collection = 'device_warranties';
  static const actionActivate = 'ACTIVATE_WARRANTY';
  static const actionVoid = 'VOID_WARRANTY';
  static const actionExtend = 'EXTEND_WARRANTY';
  static const actionSticker = 'ATTACH_WARRANTY_STICKER';
  static const targetType = 'device_warranty';
  static const statusVoided = 'voided';

  /// Deterministic id ⇒ a second activation of the same repair/service is an
  /// update, which the rules reject (no duplicates, even concurrently).
  static String docId(String repairOrderId, String serviceCategoryId) =>
      '${repairOrderId}__$serviceCategoryId';

  /// Activity-log id for the lifecycle event that moved [warrantyId] to
  /// [revision] (activation = revision 1). Rules require exactly this id.
  static String logId(String warrantyId, int revision) =>
      '${warrantyId}__r$revision';

  /// Customer-facing record code `FS-WR-XXXXXXX` (djb2 over the doc id, uint32,
  /// base36 upper-case, last 7 chars) — identical to the former TS function.
  static String recordCode(String docId) {
    var h = 5381;
    for (final unit in docId.codeUnits) {
      h = (((h << 5) + h) + unit) & 0xFFFFFFFF;
    }
    final b36 = h.toRadixString(36).toUpperCase().padLeft(7, '0');
    return 'FS-WR-${b36.substring(b36.length - 7)}';
  }

  /// Calendar-month addition in UTC, clamping the day
  /// (31 Jan + 1 month = 28/29 Feb).
  static DateTime addCalendarMonthsUtc(DateTime from, int months) {
    final f = from.toUtc();
    final m0 = f.month - 1 + months;
    // Dart ~/ truncates; % is always non-negative ⇒ floor division for m0 < 0.
    final y = f.year + ((m0 - m0 % 12) ~/ 12);
    final m = m0 % 12 + 1;
    final lastDay = DateTime.utc(y, m + 1, 0).day;
    return DateTime.utc(
      y,
      m,
      f.day > lastDay ? lastDay : f.day,
      f.hour,
      f.minute,
      f.second,
      f.millisecond,
      f.microsecond,
    );
  }

  static bool canActivate(UserRole role) =>
      role == UserRole.admin ||
      role == UserRole.manager ||
      role == UserRole.reception;

  static bool canVoidOrExtend(UserRole role) =>
      role == UserRole.admin || role == UserRole.manager;

  static bool canRecordSticker(UserRole role) =>
      canActivate(role) || role == UserRole.technician;

  static const activatableOrderStatuses = {'completed', 'delivered'};
  static const reasonMin = 3;
  static const reasonMax = 500;
  static const maxExtensionMonths = 24;

  static bool isValidReason(String? v) {
    final t = v?.trim() ?? '';
    return t.length >= reasonMin && t.length <= reasonMax;
  }

  /// Validates a repair order (raw Firestore map) for activation and resolves
  /// the warranted service. Returns a [WarrantySkipReason] or the plan.
  static ActivationCheck check({
    required String repairOrderId,
    required Map<String, dynamic>? order,
    String? fallbackCategoryId,
    String? fallbackCategoryName,
    String? fallbackPartLabel,
  }) {
    if (order == null) {
      return const ActivationCheck.skip(WarrantySkipReason.orderNotFound);
    }
    if (order['deletedAt'] != null || order['currentStatus'] == 'cancelled') {
      return const ActivationCheck.skip(WarrantySkipReason.orderCancelled);
    }
    if (!activatableOrderStatuses.contains(order['currentStatus'])) {
      return const ActivationCheck.skip(WarrantySkipReason.orderNotCompleted);
    }
    final customerId = _s(order['customerId']);
    if (customerId.isEmpty) {
      return const ActivationCheck.skip(WarrantySkipReason.missingCustomer);
    }
    final deviceId = _s(order['deviceId']);
    if (deviceId.isEmpty) {
      return const ActivationCheck.skip(WarrantySkipReason.missingDevice);
    }
    final snap =
        (order['serviceSnapshot'] as Map?)?.cast<String, dynamic>() ?? const {};
    // The order's own snapshot always wins (never a second record next to it).
    final categoryId = _s(snap['categoryId']).isNotEmpty
        ? _s(snap['categoryId'])
        : _s(fallbackCategoryId);
    if (categoryId.isEmpty) {
      return const ActivationCheck.skip(WarrantySkipReason.missingService);
    }
    final categoryName =
        _first([snap['categoryName'], fallbackCategoryName, categoryId]);
    final partLabel = _first([snap['variantName'], fallbackPartLabel]);
    return ActivationCheck._(
      skip: null,
      warrantyId: docId(repairOrderId, categoryId),
      customerId: customerId,
      deviceId: deviceId,
      categoryId: categoryId,
      categoryName: categoryName,
      partLabel: partLabel.isEmpty ? null : partLabel,
    );
  }

  /// The `device_warranties` document (without server timestamps — the
  /// caller adds activatedAt/startDate/createdAt/updatedAt = serverTimestamp).
  /// [expiresAt] is computed from the caller's clock; the rules accept ±2 h.
  static Map<String, dynamic> buildRecord({
    required String repairOrderId,
    required Map<String, dynamic> order,
    required ActivationCheck check,
    required WarrantyPlanRef plan,
    required String actorUid,
    required String actorName,
    required String note,
    required DateTime now,
  }) {
    final expiresAt = addCalendarMonthsUtc(now, plan.months);
    final n = note.trim();
    return {
      'customerId': check.customerId,
      'deviceId': check.deviceId,
      'serviceCategoryId': check.categoryId,
      'serviceCategoryName': check.categoryName,
      'status': 'active',
      'endDate': expiresAt,
      'warrantyCode': recordCode(check.warrantyId!),
      'notes': null,
      'repairOrderId': repairOrderId,
      'repairOrderCode': _orNull(order['repairOrderCode']),
      'warrantyPlanId': plan.id,
      'warrantyOptionCode': plan.code,
      'warrantyOptionLabel': plan.name,
      'warrantyMonths': plan.months,
      'partLabel': check.partLabel,
      'expiresAt': expiresAt,
      'activationSource': 'manual_staff',
      'activatedBy': actorUid,
      'activatedByName': actorName,
      'activationNote': n.isEmpty ? null : n,
      'deviceLabel':
          _first([order['deviceName'], order['deviceCode'], check.deviceId]),
      'customerName': _orNull(order['customerName']),
      'customerPhone': _orNull(order['customerPhone']),
      'deviceSerial': _orNull(order['serialNumber']),
      'deviceImei': _orNull(order['imei']),
      'stickerAttached': false,
      'stickerAttachedAt': null,
      'stickerAttachedBy': null,
      'stickerAttachedByName': null,
      'stickerCode': null,
      'revision': 1,
    };
  }

  static String _s(Object? v) => v is String ? v.trim() : '';
  static String? _orNull(Object? v) => _s(v).isEmpty ? null : _s(v);
  static String _first(List<Object?> vs) {
    for (final v in vs) {
      if (_s(v).isNotEmpty) return _s(v);
    }
    return '';
  }
}

enum WarrantySkipReason {
  orderNotFound('Không tìm thấy phiếu sửa chữa.'),
  orderCancelled('Phiếu đã hủy/xóa, không thể kích hoạt.'),
  orderNotCompleted(
      'Phiếu chưa hoàn thành — chỉ kích hoạt bảo hành khi phiếu đã hoàn thành/giao trả.'),
  missingCustomer('Phiếu chưa gắn khách hàng.'),
  missingDevice('Phiếu chưa gắn thiết bị đã đăng ký.'),
  missingService('Thiếu dịch vụ/linh kiện được bảo hành.');

  final String message;
  const WarrantySkipReason(this.message);
}

class ActivationCheck {
  final WarrantySkipReason? skip;
  final String? warrantyId;
  final String customerId;
  final String deviceId;
  final String categoryId;
  final String categoryName;
  final String? partLabel;

  const ActivationCheck._({
    required this.skip,
    required this.warrantyId,
    required this.customerId,
    required this.deviceId,
    required this.categoryId,
    required this.categoryName,
    required this.partLabel,
  });

  const ActivationCheck.skip(WarrantySkipReason reason)
      : this._(
          skip: reason,
          warrantyId: null,
          customerId: '',
          deviceId: '',
          categoryId: '',
          categoryName: '',
          partLabel: null,
        );

  bool get ok => skip == null;
}

class WarrantyPlanRef {
  final String id;
  final String code;
  final String name;
  final int months;
  const WarrantyPlanRef({
    required this.id,
    required this.code,
    required this.name,
    required this.months,
  });
}
