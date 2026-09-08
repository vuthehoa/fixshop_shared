abstract final class FirestoreConstants {
  // ── Core collections ──────────────────────────────────────────────────────
  static const String users = 'users';
  static const String customers = 'customers';

  // ── Product catalog ───────────────────────────────────────────────────────
  static const String brands = 'brands';
  static const String productFamilies = 'product_families';
  static const String models = 'models';
  static const String variants = 'variants';
  static const String repairServices = 'repair_services';

  // ── Devices ───────────────────────────────────────────────────────────────
  static const String devices = 'devices';

  // ── Repair lifecycle ──────────────────────────────────────────────────────
  static const String repairOrders = 'repair_orders';
  static const String repairHistories = 'repair_histories';

  // ── Warranties ────────────────────────────────────────────────────────────
  static const String warranties = 'warranties';

  // ── Documents (PDF metadata) ──────────────────────────────────────────────
  static const String documents = 'documents';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications = 'notifications';

  // ── Audit trail (written by Cloud Functions only) ─────────────────────────
  static const String activityLogs = 'activity_logs';
  static const String manufacturers = 'manufacturers';
  static const String products = 'products';
  static const String serviceCategories = 'service_categories';
}
