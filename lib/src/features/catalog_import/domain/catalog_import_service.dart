import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../catalog_common/domain/enums/catalog_status.dart';
import '../../manufacturer/domain/entities/manufacturer_entity.dart';
import '../../manufacturer/domain/repositories/manufacturer_repository.dart';
import '../../manufacturer/domain/value_objects/manufacturer_filter.dart';
import '../../model/domain/entities/model_entity.dart';
import '../../model/domain/repositories/model_repository.dart';
import '../../model/domain/value_objects/model_filter.dart';
import '../../product_family/domain/entities/product_family_entity.dart';
import '../../product_family/domain/repositories/product_family_repository.dart';
import '../../product_family/domain/value_objects/product_family_filter.dart';
import '../../repair_service/domain/entities/repair_service_entity.dart';
import '../../repair_service/domain/entities/repair_service_addon_entity.dart';
import '../../repair_service/domain/entities/repair_service_variant_entity.dart';
import '../../repair_service/domain/repositories/repair_service_repository.dart';
import '../../repair_service/domain/value_objects/repair_service_filter.dart';
import '../../service_category/domain/entities/service_category_entity.dart';
import '../../service_category/domain/repositories/service_category_repository.dart';
import '../../service_category/domain/value_objects/service_category_filter.dart';
import 'canonical_model_catalog.dart';
import 'catalog_import_types.dart';
import 'service_category_defs.dart';
import 'service_import_row.dart';

/// A live snapshot of the catalog hierarchy, fetched once and reused across
/// resolution/dry-run/import so every step sees a consistent view.
class CatalogAuditSnapshot {
  final List<ManufacturerEntity> manufacturers;
  final List<ProductFamilyEntity> productFamilies;
  final List<ModelEntity> models;
  final List<ServiceCategoryEntity> serviceCategories;

  const CatalogAuditSnapshot({
    required this.manufacturers,
    required this.productFamilies,
    required this.models,
    required this.serviceCategories,
  });
}

/// Internal control-flow signal — lets every repository call in a multi-step
/// method short-circuit to a single `Left(failure)` via `fold`, without
/// depending on any `Either` API beyond the `fold` method every other file
/// in this codebase already uses.
class _FailureSignal implements Exception {
  final Failure failure;
  const _FailureSignal(this.failure);
}

T _unwrap<T>(Either<Failure, T> either) {
  return either.fold((f) => throw _FailureSignal(f), (r) => r);
}

/// Orchestrates the Phase 3 production catalog import: audit the live
/// catalog, resolve/create canonical models, validate the dataset, dry-run,
/// write (idempotently — safe to rerun), and verify. Reuses the existing
/// Manufacturer/ProductFamily/Model/ServiceCategory/RepairService
/// repositories exclusively — never touches Firestore directly, per Phase 1
/// architecture and Phase 3 spec section 37.
class CatalogImportService {
  final ManufacturerRepository manufacturerRepository;
  final ProductFamilyRepository productFamilyRepository;
  final ModelRepository modelRepository;
  final ServiceCategoryRepository serviceCategoryRepository;
  final RepairServiceRepository repairServiceRepository;

  const CatalogImportService({
    required this.manufacturerRepository,
    required this.productFamilyRepository,
    required this.modelRepository,
    required this.serviceCategoryRepository,
    required this.repairServiceRepository,
  });

  /// Reads every manufacturer/product family/model/service category —
  /// active AND archived, so nothing already live is missed. Dataset sizes
  /// here are small (a few dozen at most per Phase 1 audit), so a single
  /// large page is sufficient; no cursor pagination needed.
  Future<Either<Failure, CatalogAuditSnapshot>> auditCatalog() async {
    try {
      final manufacturers = _unwrap(
        await manufacturerRepository
            .getManufacturers(const ManufacturerFilter(pageSize: 1000)),
      ).items;
      final families = _unwrap(
        await productFamilyRepository
            .getProductFamilies(const ProductFamilyFilter(pageSize: 1000)),
      ).items;
      final models = _unwrap(await modelRepository
              .getModels(const ModelFilter(pageSize: 1000)))
          .items;
      final categories = _unwrap(
        await serviceCategoryRepository
            .getServiceCategories(const ServiceCategoryFilter(pageSize: 1000)),
      ).items;

      return Right(CatalogAuditSnapshot(
        manufacturers: manufacturers,
        productFamilies: families,
        models: models,
        serviceCategories: categories,
      ));
    } on _FailureSignal catch (e) {
      return Left(e.failure);
    }
  }

  /// Creates whatever Manufacturer/ProductFamily/Model records are missing
  /// for [missingModels], reusing an existing manufacturer/family by code
  /// wherever one already exists rather than creating a duplicate. Returns
  /// the updated model list (existing + newly created) for re-resolution.
  Future<Either<Failure, List<ModelEntity>>> createMissingModels({
    required List<CanonicalModel> missingModels,
    required CatalogAuditSnapshot snapshot,
    required String createdBy,
  }) async {
    final manufacturers = [...snapshot.manufacturers];
    final families = [...snapshot.productFamilies];
    final models = [...snapshot.models];

    try {
      for (final canonical in missingModels) {
        final ManufacturerEntity manufacturer;
        final existingManufacturer = _findFirst(
            manufacturers, (m) => m.code == canonical.manufacturerCode);
        if (existingManufacturer != null) {
          manufacturer = existingManufacturer;
        } else {
          final now = DateTime.now();
          manufacturer =
              _unwrap(await manufacturerRepository.createManufacturer(
            ManufacturerEntity(
              id: '',
              code: canonical.manufacturerCode,
              name: canonical.manufacturerName,
              createdAt: now,
              updatedAt: now,
              createdBy: createdBy,
            ),
          ));
          manufacturers.add(manufacturer);
        }

        final ProductFamilyEntity family;
        final existingFamily = _findFirst(
          families,
          (f) =>
              f.code == canonical.familyCode &&
              f.manufacturerId == manufacturer.id,
        );
        if (existingFamily != null) {
          family = existingFamily;
        } else {
          final now = DateTime.now();
          family = _unwrap(await productFamilyRepository.createProductFamily(
            ProductFamilyEntity(
              id: '',
              code: canonical.familyCode,
              name: canonical.familyName,
              manufacturerId: manufacturer.id,
              createdAt: now,
              updatedAt: now,
              createdBy: createdBy,
            ),
          ));
          families.add(family);
        }

        final now = DateTime.now();
        final model = _unwrap(await modelRepository.createModel(
          ModelEntity(
            id: '',
            code: canonical.modelCode,
            name: canonical.modelName,
            productFamilyId: family.id,
            createdAt: now,
            updatedAt: now,
            createdBy: createdBy,
          ),
        ));
        models.add(model);
      }

      return Right(models);
    } on _FailureSignal catch (e) {
      return Left(e.failure);
    }
  }

  /// Creates or updates the 14 service categories. Idempotent: a category
  /// already present (matched by `code`) is updated in place — `createdAt`/
  /// `createdBy` are preserved (Phase 3 spec section 32).
  Future<Either<Failure, CategoryImportOutcome>> importCategories({
    required List<ServiceCategoryDef> categories,
    required List<ServiceCategoryEntity> existing,
    required String createdBy,
  }) async {
    final existingByCode = {for (final c in existing) c.code: c};
    final idByCode = <String, String>{};
    var created = 0;
    var updated = 0;

    try {
      for (final def in categories) {
        final current = existingByCode[def.code];
        if (current == null) {
          final now = DateTime.now();
          final saved =
              _unwrap(await serviceCategoryRepository.createServiceCategory(
            ServiceCategoryEntity(
              id: '',
              code: def.code,
              name: def.name,
              enabled: true,
              order: def.order,
              status: CatalogStatus.active,
              createdAt: now,
              updatedAt: now,
              createdBy: createdBy,
            ),
          ));
          idByCode[def.code] = saved.id;
          created++;
        } else {
          _unwrap(await serviceCategoryRepository.updateServiceCategory(
            current.copyWith(
                name: def.name, order: def.order, updatedAt: DateTime.now()),
          ));
          idByCode[def.code] = current.id;
          updated++;
        }
      }

      return Right(CategoryImportOutcome(
          idByCode: idByCode, created: created, updated: updated));
    } on _FailureSignal catch (e) {
      return Left(e.failure);
    }
  }

  /// Creates or updates each production service row. Idempotent — matched
  /// by the (categoryId, modelId) business key (never auto-generated
  /// deterministic doc IDs, since the existing datasource already enforces
  /// that uniqueness; see Phase 3 spec section 27's documented fallback).
  Future<Either<Failure, ServiceImportOutcome>> importServices({
    required List<ServiceImportRow> rows,
    required Map<String, String> categoryIdByCode,
    required Map<String, String> categoryNameByCode,
    required Map<String, String> modelIdByShorthand,
    required Map<String, String> modelNameByShorthand,
    required String createdBy,
  }) async {
    var created = 0;
    var updated = 0;

    try {
      for (final row in rows) {
        final categoryId = categoryIdByCode[row.categoryCode]!;
        final modelId = modelIdByShorthand[row.modelShorthand]!;
        final serviceName =
            '${categoryNameByCode[row.categoryCode]} — ${modelNameByShorthand[row.modelShorthand]}';

        // `order` mirrors each variant/addon's position in the source
        // dataset row — the price table's own listing order (e.g. "Cell
        // zin 1:1" before "Pin Pisen") is meaningful and must survive the
        // import, not collapse to alphabetical-by-name because every
        // record got the same order=0 default (Phase 3.2 preflight audit).
        final variants = <RepairServiceVariantEntity>[];
        for (var vi = 0; vi < row.variants.length; vi++) {
          final v = row.variants[vi];
          final addons = <RepairServiceAddonEntity>[];
          for (var ai = 0; ai < v.addons.length; ai++) {
            final a = v.addons[ai];
            addons.add(RepairServiceAddonEntity(
              code: a.code,
              name: a.name,
              price: a.price,
              order: ai * 10,
            ));
          }
          variants.add(RepairServiceVariantEntity(
            code: v.code,
            name: v.name,
            customerDisplayName: v.customerDisplayName,
            price: v.price,
            order: vi * 10,
            addons: addons,
          ));
        }

        final matches = _unwrap(await repairServiceRepository.getRepairServices(
          RepairServiceFilter(
              categoryId: categoryId, parentId: modelId, pageSize: 5),
        ))
            .items;

        if (matches.isEmpty) {
          final now = DateTime.now();
          _unwrap(await repairServiceRepository.createRepairService(
            RepairServiceEntity(
              id: '',
              categoryId: categoryId,
              modelId: modelId,
              name: serviceName,
              enabled: true,
              order: 0,
              variants: variants,
              status: CatalogStatus.active,
              createdAt: now,
              updatedAt: now,
              createdBy: createdBy,
            ),
          ));
          created++;
        } else {
          // Rerun-safe: preserves createdAt/createdBy/enabled/order/status —
          // only the name and variants (the price data itself) are refreshed.
          final existing = matches.first;
          _unwrap(await repairServiceRepository.updateRepairService(
            existing.copyWith(
                name: serviceName,
                variants: variants,
                updatedAt: DateTime.now()),
          ));
          updated++;
        }
      }

      return Right(ServiceImportOutcome(created: created, updated: updated));
    } on _FailureSignal catch (e) {
      return Left(e.failure);
    }
  }

  /// Re-reads every imported (category, model) pair and compares prices
  /// against the source dataset. See Phase 3 spec sections 42-46.
  Future<VerifyReport> verify({
    required List<ServiceImportRow> rows,
    required Map<String, String> categoryIdByCode,
    required Map<String, String> modelIdByShorthand,
  }) async {
    final mismatches = <PriceMismatch>[];
    final orphans = <String>[];
    final notBookingReady = <String>[];
    final seenMappings = <String>{};
    final duplicateMappings = <String>[];
    var checked = 0;

    for (final row in rows) {
      final categoryId = categoryIdByCode[row.categoryCode];
      final modelId = modelIdByShorthand[row.modelShorthand];
      if (categoryId == null || modelId == null) {
        orphans.add(
            '${row.categoryCode}/${row.modelShorthand}: unresolved category or model id');
        continue;
      }

      final mappingKey = '$categoryId::$modelId';
      if (!seenMappings.add(mappingKey)) {
        duplicateMappings.add(mappingKey);
      }

      final result = await repairServiceRepository.getRepairServices(
        RepairServiceFilter(
            categoryId: categoryId, parentId: modelId, pageSize: 5),
      );
      final matches = result.fold(
          (_) => const <RepairServiceEntity>[], (page) => page.items);
      checked++;

      if (matches.isEmpty) {
        for (final v in row.variants) {
          mismatches.add(PriceMismatch(
            categoryCode: row.categoryCode,
            modelShorthand: row.modelShorthand,
            variantCode: v.code,
            expectedPrice: v.price,
          ));
        }
        continue;
      }

      final live = matches.first;
      if (!live.isBookingReady) {
        notBookingReady.add('${row.categoryCode}/${row.modelShorthand}');
      }

      final liveVariantsByCode = {for (final v in live.variants) v.code: v};
      for (final expectedVariant in row.variants) {
        final liveVariant = liveVariantsByCode[expectedVariant.code];
        if (liveVariant == null || liveVariant.price != expectedVariant.price) {
          mismatches.add(PriceMismatch(
            categoryCode: row.categoryCode,
            modelShorthand: row.modelShorthand,
            variantCode: expectedVariant.code,
            expectedPrice: expectedVariant.price,
            actualPrice: liveVariant?.price,
          ));
        }
        if (liveVariant == null) continue;

        final liveAddonsByCode = {
          for (final a in liveVariant.addons) a.code: a
        };
        for (final expectedAddon in expectedVariant.addons) {
          final liveAddon = liveAddonsByCode[expectedAddon.code];
          if (liveAddon == null || liveAddon.price != expectedAddon.price) {
            mismatches.add(PriceMismatch(
              categoryCode: row.categoryCode,
              modelShorthand: row.modelShorthand,
              variantCode: expectedVariant.code,
              addonCode: expectedAddon.code,
              expectedPrice: expectedAddon.price,
              actualPrice: liveAddon?.price,
            ));
          }
        }
      }
    }

    return VerifyReport(
      recordsChecked: checked,
      priceMismatches: mismatches,
      duplicateCategoryCodes: const [], // checked separately, at category-import time
      duplicateMappings: duplicateMappings,
      orphanServices: orphans,
      notBookingReady: notBookingReady,
    );
  }
}

class CategoryImportOutcome {
  final Map<String, String> idByCode;
  final int created;
  final int updated;
  const CategoryImportOutcome(
      {required this.idByCode, required this.created, required this.updated});
}

class ServiceImportOutcome {
  final int created;
  final int updated;
  const ServiceImportOutcome({required this.created, required this.updated});
}

T? _findFirst<T>(List<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}
