import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/paginated_result.dart';
import '../../domain/value_objects/customer_filter.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<CustomerModel> getCustomer(String id);

  Future<PaginatedResult<CustomerModel>> getCustomers(
    CustomerFilter filter, {
    DocumentSnapshot? startAfter,
  });

  Future<List<CustomerModel>> getActiveCustomers();

  Future<CustomerModel> createCustomer(CustomerModel entity);

  Future<CustomerModel> updateCustomer(CustomerModel entity);

  Future<void> archiveCustomer(String id);

  Future<void> restoreCustomer(String id);
}
