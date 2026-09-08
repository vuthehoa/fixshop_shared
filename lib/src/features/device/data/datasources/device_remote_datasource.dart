import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/paginated_result.dart';
import '../../domain/value_objects/device_filter.dart';
import '../models/device_model.dart';

abstract class DeviceRemoteDataSource {
  Future<DeviceModel> getDevice(String id);

  Future<DeviceModel> getDeviceByCode(String deviceCode);

  Future<PaginatedResult<DeviceModel>> getDevices(
    DeviceFilter filter, {
    DocumentSnapshot? startAfter,
  });

  Future<List<DeviceModel>> getActiveDevices({String? customerId});

  Future<DeviceModel> createDevice(DeviceModel entity);

  Future<DeviceModel> updateDevice(DeviceModel entity);

  Future<void> archiveDevice(String id);

  Future<void> restoreDevice(String id);

  Future<DeviceModel> activateWarranty(String id,
      {required int warrantyPeriodMonths});

  Future<DeviceModel> voidWarranty(String id);

  Future<DeviceModel> restoreWarranty(String id);
}
