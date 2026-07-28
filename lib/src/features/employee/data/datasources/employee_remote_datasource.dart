import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/paginated_result.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/value_objects/employee_filter.dart';

abstract class EmployeeRemoteDataSource {
  Future<UserModel> getEmployee(String id);

  Future<PaginatedResult<UserModel>> getEmployees(
    EmployeeFilter filter, {
    DocumentSnapshot? startAfter,
  });

  Future<UserModel> createEmployee({
    required String email,
    required String password,
    required UserModel employee,
  });

  Future<UserModel> updateEmployee(UserModel employee);

  Future<void> deleteEmployee(String id);

  Future<void> updateEmployeeStatus(String id, UserStatus status);

  Future<void> resetEmployeePassword(String email);
}
