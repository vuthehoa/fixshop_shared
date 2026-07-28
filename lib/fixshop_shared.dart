// Core — constants
export 'src/core/constants/app_constants.dart';
export 'src/core/constants/firestore_constants.dart';

// Core — error
export 'src/core/error/exceptions.dart';
export 'src/core/error/failures.dart';

// Core — use cases
export 'src/core/usecases/usecase.dart';

// Core — utils
export 'src/core/utils/paginated_result.dart';

// Core — permissions
export 'src/core/permissions/permission.dart';
export 'src/core/permissions/role_permission.dart';
export 'src/core/permissions/permission_resolver.dart';

// Core — theme tokens
export 'src/core/theme/app_colors.dart';
export 'src/core/theme/app_text_styles.dart';
export 'src/core/theme/app_spacing.dart';
export 'src/core/theme/app_radius.dart';
export 'src/core/theme/app_shadows.dart';

// Core — extensions
export 'src/core/extensions/string_extensions.dart';
export 'src/core/extensions/datetime_extensions.dart';

// Auth — domain
export 'src/features/auth/domain/entities/user_entity.dart';
export 'src/features/auth/domain/repositories/auth_repository.dart';
export 'src/features/auth/domain/usecases/login_usecase.dart';
export 'src/features/auth/domain/usecases/logout_usecase.dart';
export 'src/features/auth/domain/usecases/get_current_user_usecase.dart';
export 'src/features/auth/domain/usecases/change_password_usecase.dart';
export 'src/features/auth/domain/usecases/check_email_verified_usecase.dart';
export 'src/features/auth/domain/usecases/resend_verification_email_usecase.dart';

// Auth — data
export 'src/features/auth/data/models/user_model.dart';
export 'src/features/auth/data/datasources/auth_remote_datasource.dart';
export 'src/features/auth/data/datasources/firebase_auth_remote_datasource.dart';
export 'src/features/auth/data/repositories/auth_repository_impl.dart';

// Employee — domain
export 'src/features/employee/domain/value_objects/employee_filter.dart';
export 'src/features/employee/domain/repositories/employee_repository.dart';
export 'src/features/employee/domain/usecases/get_employee_usecase.dart';
export 'src/features/employee/domain/usecases/get_employees_usecase.dart';
export 'src/features/employee/domain/usecases/create_employee_usecase.dart';
export 'src/features/employee/domain/usecases/update_employee_usecase.dart';
export 'src/features/employee/domain/usecases/delete_employee_usecase.dart';
export 'src/features/employee/domain/usecases/reset_employee_password_usecase.dart';
export 'src/features/employee/domain/usecases/update_employee_status_usecase.dart';

// Employee — data
export 'src/features/employee/data/datasources/employee_remote_datasource.dart';
export 'src/features/employee/data/datasources/firebase_employee_remote_datasource.dart';
export 'src/features/employee/data/repositories/employee_repository_impl.dart';

// Activity Log — domain
export 'src/features/activity_log/domain/entities/activity_log_entity.dart';
export 'src/features/activity_log/domain/repositories/activity_log_repository.dart';
export 'src/features/activity_log/domain/usecases/write_activity_log_usecase.dart';

// Activity Log — data
export 'src/features/activity_log/data/models/activity_log_model.dart';
export 'src/features/activity_log/data/datasources/activity_log_remote_datasource.dart';
export 'src/features/activity_log/data/datasources/firebase_activity_log_remote_datasource.dart';
export 'src/features/activity_log/data/repositories/activity_log_repository_impl.dart';
