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
export 'src/core/permissions/staff_directory_policy.dart';

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

// Existing APIs referenced by CMS; restored from analyzer-confirmed missing symbols.
export 'src/core/qr/qr_code_service.dart';
export 'src/features/auth/domain/admin_bootstrap_policy.dart';
export 'src/features/catalog_common/domain/enums/catalog_status.dart';
export 'src/features/catalog_import/domain/canonical_model_catalog.dart';
export 'src/features/catalog_import/domain/catalog_dataset_preflight.dart';
export 'src/features/catalog_import/domain/catalog_import_service.dart';
export 'src/features/catalog_import/domain/catalog_import_types.dart';
export 'src/features/catalog_import/domain/service_category_defs.dart';
export 'src/features/catalog_import/domain/service_import_row.dart';
export 'src/features/customer/data/datasources/customer_remote_datasource.dart';
export 'src/features/customer/data/datasources/firebase_customer_remote_datasource.dart';
export 'src/features/customer/data/repositories/customer_repository_impl.dart';
export 'src/features/customer/domain/entities/customer_entity.dart';
export 'src/features/customer/domain/repositories/customer_repository.dart';
export 'src/features/customer/domain/usecases/archive_customer_usecase.dart';
export 'src/features/customer/domain/usecases/create_customer_usecase.dart';
export 'src/features/customer/domain/usecases/get_active_customers_usecase.dart';
export 'src/features/customer/domain/usecases/get_customer_usecase.dart';
export 'src/features/customer/domain/usecases/get_customers_usecase.dart';
export 'src/features/customer/domain/usecases/restore_customer_usecase.dart';
export 'src/features/customer/domain/usecases/update_customer_usecase.dart';
export 'src/features/customer/domain/value_objects/customer_filter.dart';
export 'src/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
export 'src/features/dashboard/data/datasources/firebase_dashboard_remote_datasource.dart';
export 'src/features/dashboard/data/repositories/dashboard_repository_impl.dart';
export 'src/features/dashboard/domain/entities/dashboard_summary.dart';
export 'src/features/dashboard/domain/repositories/dashboard_repository.dart';
export 'src/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
export 'src/features/device/data/datasources/device_remote_datasource.dart';
export 'src/features/device/data/datasources/firebase_device_remote_datasource.dart';
export 'src/features/device/data/repositories/device_repository_impl.dart';
export 'src/features/device/domain/entities/device_entity.dart';
export 'src/features/device/domain/repositories/device_repository.dart';
export 'src/features/device/domain/usecases/activate_device_warranty_usecase.dart';
export 'src/features/device/domain/usecases/archive_device_usecase.dart';
export 'src/features/device/domain/usecases/create_device_usecase.dart';
export 'src/features/device/domain/usecases/get_active_devices_usecase.dart';
export 'src/features/device/domain/usecases/get_device_usecase.dart';
export 'src/features/device/domain/usecases/get_devices_usecase.dart';
export 'src/features/device/domain/usecases/lookup_device_by_qr_usecase.dart';
export 'src/features/device/domain/usecases/restore_device_usecase.dart';
export 'src/features/device/domain/usecases/restore_device_warranty_usecase.dart';
export 'src/features/device/domain/usecases/update_device_usecase.dart';
export 'src/features/device/domain/usecases/void_device_warranty_usecase.dart';
export 'src/features/device/domain/value_objects/device_filter.dart';
export 'src/features/manufacturer/data/datasources/firebase_manufacturer_remote_datasource.dart';
export 'src/features/manufacturer/data/datasources/manufacturer_remote_datasource.dart';
export 'src/features/manufacturer/data/repositories/manufacturer_repository_impl.dart';
export 'src/features/manufacturer/domain/entities/manufacturer_entity.dart';
export 'src/features/manufacturer/domain/repositories/manufacturer_repository.dart';
export 'src/features/manufacturer/domain/usecases/archive_manufacturer_usecase.dart';
export 'src/features/manufacturer/domain/usecases/create_manufacturer_usecase.dart';
export 'src/features/manufacturer/domain/usecases/get_active_manufacturers_usecase.dart';
export 'src/features/manufacturer/domain/usecases/get_manufacturer_usecase.dart';
export 'src/features/manufacturer/domain/usecases/get_manufacturers_usecase.dart';
export 'src/features/manufacturer/domain/usecases/restore_manufacturer_usecase.dart';
export 'src/features/manufacturer/domain/usecases/update_manufacturer_usecase.dart';
export 'src/features/manufacturer/domain/value_objects/manufacturer_filter.dart';
export 'src/features/model/data/datasources/firebase_model_remote_datasource.dart';
export 'src/features/model/data/datasources/model_remote_datasource.dart';
export 'src/features/model/data/repositories/model_repository_impl.dart';
export 'src/features/model/domain/entities/model_entity.dart';
export 'src/features/model/domain/repositories/model_repository.dart';
export 'src/features/model/domain/usecases/archive_model_usecase.dart';
export 'src/features/model/domain/usecases/create_model_usecase.dart';
export 'src/features/model/domain/usecases/get_active_models_usecase.dart';
export 'src/features/model/domain/usecases/get_model_usecase.dart';
export 'src/features/model/domain/usecases/get_models_usecase.dart';
export 'src/features/model/domain/usecases/restore_model_usecase.dart';
export 'src/features/model/domain/usecases/update_model_usecase.dart';
export 'src/features/model/domain/value_objects/model_filter.dart';
export 'src/features/notification/data/datasources/firebase_notification_remote_datasource.dart';
export 'src/features/notification/data/datasources/notification_remote_datasource.dart';
export 'src/features/notification/data/repositories/notification_repository_impl.dart';
export 'src/features/notification/domain/entities/notification_entity.dart';
export 'src/features/notification/domain/repositories/notification_repository.dart';
export 'src/features/notification/domain/usecases/create_notification_usecase.dart';
export 'src/features/notification/domain/usecases/get_notifications_usecase.dart';
export 'src/features/notification/domain/usecases/mark_notification_read_usecase.dart';
export 'src/features/notification/domain/usecases/scan_warranty_expiring_notifications_usecase.dart';
export 'src/features/notification/domain/value_objects/notification_filter.dart';
export 'src/features/product/data/datasources/firebase_shop_product_remote_datasource.dart';
export 'src/features/product/data/datasources/shop_product_remote_datasource.dart';
export 'src/features/product/data/repositories/shop_product_repository_impl.dart';
export 'src/features/product/data/services/firebase_product_image_storage_service.dart';
export 'src/features/product/domain/entities/product_image.dart';
export 'src/features/product/domain/entities/shop_product_entity.dart';
export 'src/features/product/domain/enums/product_condition.dart';
export 'src/features/product/domain/enums/product_status.dart';
export 'src/features/product/domain/repositories/product_image_storage_service.dart';
export 'src/features/product/domain/repositories/shop_product_repository.dart';
export 'src/features/product/domain/usecases/archive_shop_product_usecase.dart';
export 'src/features/product/domain/usecases/create_shop_product_usecase.dart';
export 'src/features/product/domain/usecases/get_shop_product_usecase.dart';
export 'src/features/product/domain/usecases/get_shop_products_usecase.dart';
export 'src/features/product/domain/usecases/set_shop_product_published_usecase.dart';
export 'src/features/product/domain/usecases/update_shop_product_usecase.dart';
export 'src/features/product/domain/value_objects/shop_product_filter.dart';
export 'src/features/product_family/data/datasources/firebase_product_family_remote_datasource.dart';
export 'src/features/product_family/data/datasources/product_family_remote_datasource.dart';
export 'src/features/product_family/data/repositories/product_family_repository_impl.dart';
export 'src/features/product_family/domain/entities/product_family_entity.dart';
export 'src/features/product_family/domain/repositories/product_family_repository.dart';
export 'src/features/product_family/domain/usecases/archive_product_family_usecase.dart';
export 'src/features/product_family/domain/usecases/create_product_family_usecase.dart';
export 'src/features/product_family/domain/usecases/get_active_product_families_usecase.dart';
export 'src/features/product_family/domain/usecases/get_product_families_usecase.dart';
export 'src/features/product_family/domain/usecases/get_product_family_usecase.dart';
export 'src/features/product_family/domain/usecases/restore_product_family_usecase.dart';
export 'src/features/product_family/domain/usecases/update_product_family_usecase.dart';
export 'src/features/product_family/domain/value_objects/product_family_filter.dart';
export 'src/features/repair_order/data/datasources/firebase_repair_order_remote_datasource.dart';
export 'src/features/repair_order/data/datasources/repair_order_remote_datasource.dart';
export 'src/features/repair_order/data/repositories/repair_order_repository_impl.dart';
export 'src/features/repair_order/domain/entities/delivery_info.dart';
export 'src/features/repair_order/domain/entities/reception_info.dart';
export 'src/features/repair_order/domain/entities/repair_booking_snapshot.dart';
export 'src/features/repair_order/domain/entities/repair_execution_info.dart';
export 'src/features/repair_order/domain/entities/repair_order_entity.dart';
export 'src/features/repair_order/domain/entities/repair_order_timeline_entry.dart';
export 'src/features/repair_order/domain/repositories/repair_order_repository.dart';
export 'src/features/repair_order/domain/services/repair_order_status_transition_service.dart';
export 'src/features/repair_order/domain/services/repair_order_role_policy.dart';
export 'src/features/repair_order/domain/usecases/assign_repair_order_technician_usecase.dart';
export 'src/features/repair_order/domain/usecases/cancel_repair_order_usecase.dart';
export 'src/features/repair_order/domain/usecases/change_repair_order_status_usecase.dart';
export 'src/features/repair_order/domain/usecases/complete_diagnosis_usecase.dart';
export 'src/features/repair_order/domain/usecases/create_repair_order_usecase.dart';
export 'src/features/repair_order/domain/usecases/deliver_repair_order_usecase.dart';
export 'src/features/repair_order/domain/usecases/fail_testing_usecase.dart';
export 'src/features/repair_order/domain/usecases/get_repair_order_usecase.dart';
export 'src/features/repair_order/domain/usecases/get_repair_orders_usecase.dart';
export 'src/features/repair_order/domain/usecases/pass_testing_usecase.dart';
export 'src/features/repair_order/domain/usecases/receive_repair_order_usecase.dart';
export 'src/features/repair_order/domain/usecases/start_diagnosis_usecase.dart';
export 'src/features/repair_order/domain/usecases/start_repair_usecase.dart';
export 'src/features/repair_order/domain/usecases/submit_for_testing_usecase.dart';
export 'src/features/repair_order/domain/usecases/update_reception_info_usecase.dart';
export 'src/features/repair_order/domain/usecases/update_repair_execution_usecase.dart';
export 'src/features/repair_order/domain/usecases/update_repair_order_diagnosis_usecase.dart';
export 'src/features/repair_order/domain/usecases/update_repair_order_usecase.dart';
export 'src/features/repair_order/domain/value_objects/repair_order_filter.dart';
export 'src/features/repair_service/data/datasources/firebase_repair_service_remote_datasource.dart';
export 'src/features/repair_service/data/datasources/repair_service_remote_datasource.dart';
export 'src/features/repair_service/data/repositories/repair_service_repository_impl.dart';
export 'src/features/repair_service/domain/entities/repair_service_addon_entity.dart';
export 'src/features/repair_service/domain/entities/repair_service_entity.dart';
export 'src/features/repair_service/domain/entities/repair_service_variant_entity.dart';
export 'src/features/repair_service/domain/repositories/repair_service_repository.dart';
export 'src/features/repair_service/domain/usecases/archive_repair_service_usecase.dart';
export 'src/features/repair_service/domain/usecases/create_repair_service_usecase.dart';
export 'src/features/repair_service/domain/usecases/get_active_repair_services_usecase.dart';
export 'src/features/repair_service/domain/usecases/get_repair_service_usecase.dart';
export 'src/features/repair_service/domain/usecases/get_repair_services_usecase.dart';
export 'src/features/repair_service/domain/usecases/restore_repair_service_usecase.dart';
export 'src/features/repair_service/domain/usecases/update_repair_service_usecase.dart';
export 'src/features/repair_service/domain/value_objects/repair_service_filter.dart';
export 'src/features/repair_service/domain/value_objects/repair_service_write_context.dart';
export 'src/features/repair_service/domain/services/catalog_eligibility.dart';
export 'src/features/repair_service/domain/services/catalog_model_offers.dart';
export 'src/features/service_category/data/datasources/firebase_service_category_remote_datasource.dart';
export 'src/features/service_category/data/datasources/service_category_remote_datasource.dart';
export 'src/features/service_category/data/repositories/service_category_repository_impl.dart';
export 'src/features/service_category/domain/entities/service_category_entity.dart';
export 'src/features/service_category/domain/repositories/service_category_repository.dart';
export 'src/features/service_category/domain/usecases/archive_service_category_usecase.dart';
export 'src/features/service_category/domain/usecases/create_service_category_usecase.dart';
export 'src/features/service_category/domain/usecases/get_active_service_categories_usecase.dart';
export 'src/features/service_category/domain/usecases/get_service_categories_usecase.dart';
export 'src/features/service_category/domain/usecases/get_service_category_usecase.dart';
export 'src/features/service_category/domain/usecases/restore_service_category_usecase.dart';
export 'src/features/service_category/domain/usecases/update_service_category_usecase.dart';
export 'src/features/service_category/domain/value_objects/service_category_filter.dart';
export 'src/features/variant/data/datasources/firebase_variant_remote_datasource.dart';
export 'src/features/variant/data/datasources/variant_remote_datasource.dart';
export 'src/features/variant/data/repositories/variant_repository_impl.dart';
export 'src/features/variant/domain/entities/variant_entity.dart';
export 'src/features/variant/domain/repositories/variant_repository.dart';
export 'src/features/variant/domain/usecases/archive_variant_usecase.dart';
export 'src/features/variant/domain/usecases/create_variant_usecase.dart';
export 'src/features/variant/domain/usecases/get_active_variants_usecase.dart';
export 'src/features/variant/domain/usecases/get_variant_usecase.dart';
export 'src/features/variant/domain/usecases/get_variants_usecase.dart';
export 'src/features/variant/domain/usecases/restore_variant_usecase.dart';
export 'src/features/variant/domain/usecases/update_variant_usecase.dart';
export 'src/features/variant/domain/value_objects/variant_filter.dart';
export 'src/features/catalog_import/domain/catalog_model_resolver.dart';
export 'src/features/catalog_import/domain/production_catalog_dataset.dart';
export 'src/core/qr/qr_payload_builder.dart';
export 'src/features/dashboard/domain/services/dashboard_aggregator.dart';
export 'src/features/employee/domain/value_objects/employee_query_plan.dart';
export 'src/features/employee/domain/value_objects/employee_page_assembler.dart';
export 'src/features/repair_order/data/models/repair_order_model.dart';
export 'src/features/repair_service/data/models/repair_service_model.dart';
export 'src/features/repair_service/data/models/catalog_eligibility_model.dart';
export 'src/features/repair_service/data/models/catalog_model_offers_model.dart';
export 'src/features/service_category/data/models/service_category_model.dart';
export 'src/features/product/data/models/shop_product_model.dart';
export 'src/features/device_warranty/domain/device_warranty_activation.dart';
