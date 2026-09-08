import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';

abstract final class ActivityActions {
  // Employee
  static const String createEmployee = 'CREATE_EMPLOYEE';
  static const String updateEmployee = 'UPDATE_EMPLOYEE';
  static const String disableEmployee = 'DISABLE_EMPLOYEE';
  static const String activateEmployee = 'ACTIVATE_EMPLOYEE';
  static const String deleteEmployee = 'DELETE_EMPLOYEE';
  static const String resetEmployeePassword = 'RESET_EMPLOYEE_PASSWORD';
  static const String updateEmployeeRole = 'UPDATE_EMPLOYEE_ROLE';

  // Future modules (declared now so logging is consistent)
  static const String createRepairOrder = 'CREATE_REPAIR_ORDER';
  static const String updateRepairOrder = 'UPDATE_REPAIR_ORDER';
  static const String completeRepairOrder = 'COMPLETE_REPAIR_ORDER';
  static const String createCustomer = 'CREATE_CUSTOMER';
  static const String updateCustomer = 'UPDATE_CUSTOMER';
  static const String activateWarranty = 'ACTIVATE_WARRANTY';
  static const String archiveCustomer = 'ARCHIVE_CUSTOMER';
  static const String archiveDevice = 'ARCHIVE_DEVICE';
  static const String archiveManufacturer = 'ARCHIVE_MANUFACTURER';
  static const String archiveModel = 'ARCHIVE_MODEL';
  static const String archiveProductFamily = 'ARCHIVE_PRODUCT_FAMILY';
  static const String archiveRepairService = 'ARCHIVE_REPAIR_SERVICE';
  static const String archiveServiceCategory = 'ARCHIVE_SERVICE_CATEGORY';
  static const String archiveShopProduct = 'ARCHIVE_SHOP_PRODUCT';
  static const String archiveVariant = 'ARCHIVE_VARIANT';
  static const String assignRepairOrderTechnician =
      'ASSIGN_REPAIR_ORDER_TECHNICIAN';
  static const String cancelRepairOrder = 'CANCEL_REPAIR_ORDER';
  static const String changeRepairOrderStatus = 'CHANGE_REPAIR_ORDER_STATUS';
  static const String completeDiagnosis = 'COMPLETE_DIAGNOSIS';
  static const String createDevice = 'CREATE_DEVICE';
  static const String createManufacturer = 'CREATE_MANUFACTURER';
  static const String createModel = 'CREATE_MODEL';
  static const String createProductFamily = 'CREATE_PRODUCT_FAMILY';
  static const String createRepairService = 'CREATE_REPAIR_SERVICE';
  static const String createServiceCategory = 'CREATE_SERVICE_CATEGORY';
  static const String createShopProduct = 'CREATE_SHOP_PRODUCT';
  static const String createVariant = 'CREATE_VARIANT';
  static const String deliverRepairOrderDevice = 'DELIVER_REPAIR_ORDER_DEVICE';
  static const String expireWarranty = 'EXPIRE_WARRANTY';
  static const String failTesting = 'FAIL_TESTING';
  static const String generateQr = 'GENERATE_QR';
  static const String passTesting = 'PASS_TESTING';
  static const String publishShopProduct = 'PUBLISH_SHOP_PRODUCT';
  static const String receiveRepairOrderDevice = 'RECEIVE_REPAIR_ORDER_DEVICE';
  static const String registerDevice = 'REGISTER_DEVICE';
  static const String restoreCustomer = 'RESTORE_CUSTOMER';
  static const String restoreDevice = 'RESTORE_DEVICE';
  static const String restoreManufacturer = 'RESTORE_MANUFACTURER';
  static const String restoreModel = 'RESTORE_MODEL';
  static const String restoreProductFamily = 'RESTORE_PRODUCT_FAMILY';
  static const String restoreRepairService = 'RESTORE_REPAIR_SERVICE';
  static const String restoreServiceCategory = 'RESTORE_SERVICE_CATEGORY';
  static const String restoreShopProduct = 'RESTORE_SHOP_PRODUCT';
  static const String restoreVariant = 'RESTORE_VARIANT';
  static const String restoreWarranty = 'RESTORE_WARRANTY';
  static const String scanWarrantyExpirations = 'SCAN_WARRANTY_EXPIRATIONS';
  static const String startDiagnosis = 'START_DIAGNOSIS';
  static const String startRepair = 'START_REPAIR';
  static const String submitForTesting = 'SUBMIT_FOR_TESTING';
  static const String unpublishShopProduct = 'UNPUBLISH_SHOP_PRODUCT';
  static const String updateDevice = 'UPDATE_DEVICE';
  static const String updateManufacturer = 'UPDATE_MANUFACTURER';
  static const String updateModel = 'UPDATE_MODEL';
  static const String updateProductFamily = 'UPDATE_PRODUCT_FAMILY';
  static const String updateRepairExecution = 'UPDATE_REPAIR_EXECUTION';
  static const String updateRepairService = 'UPDATE_REPAIR_SERVICE';
  static const String updateServiceCategory = 'UPDATE_SERVICE_CATEGORY';
  static const String updateShopProduct = 'UPDATE_SHOP_PRODUCT';
  static const String updateVariant = 'UPDATE_VARIANT';
}

abstract final class ActivityTargetTypes {
  static const String employee = 'employee';
  static const String repairOrder = 'repair_order';
  static const String customer = 'customer';
  static const String device = 'device';
  static const String manufacturer = 'manufacturer';
  static const String model = 'model';
  static const String productFamily = 'product_family';
  static const String repairService = 'repair_service';
  static const String serviceCategory = 'service_category';
  static const String shopProduct = 'shop_product';
  static const String variant = 'variant';
}

class ActivityLogEntity extends Equatable {
  final String id;
  final String actorId;
  final UserRole actorRole;
  final String action;
  final String? targetId;
  final String? targetType;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  const ActivityLogEntity({
    required this.id,
    required this.actorId,
    required this.actorRole,
    required this.action,
    this.targetId,
    this.targetType,
    this.metadata,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        actorId,
        actorRole,
        action,
        targetId,
        targetType,
        metadata,
        timestamp,
      ];
}
