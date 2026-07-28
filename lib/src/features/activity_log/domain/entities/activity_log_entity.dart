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
}

abstract final class ActivityTargetTypes {
  static const String employee = 'employee';
  static const String repairOrder = 'repair_order';
  static const String customer = 'customer';
  static const String device = 'device';
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
