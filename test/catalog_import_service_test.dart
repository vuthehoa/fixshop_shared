import 'package:dartz/dartz.dart';
import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockManufacturerRepository extends Mock
    implements ManufacturerRepository {}

class _MockProductFamilyRepository extends Mock
    implements ProductFamilyRepository {}

class _MockModelRepository extends Mock implements ModelRepository {}

class _MockServiceCategoryRepository extends Mock
    implements ServiceCategoryRepository {}

class _MockRepairServiceRepository extends Mock
    implements RepairServiceRepository {}

DateTime get _now => DateTime(2026, 1, 1);

ManufacturerEntity _manufacturer(String code, {String id = 'mfr-1'}) =>
    ManufacturerEntity(
      id: id,
      code: code,
      name: code,
      createdAt: _now,
      updatedAt: _now,
    );

ProductFamilyEntity _family(String code, String manufacturerId,
        {String id = 'family-1'}) =>
    ProductFamilyEntity(
      id: id,
      code: code,
      name: code,
      manufacturerId: manufacturerId,
      createdAt: _now,
      updatedAt: _now,
    );

ModelEntity _modelEntity(String code, String familyId,
        {String id = 'model-1'}) =>
    ModelEntity(
      id: id,
      code: code,
      name: code,
      productFamilyId: familyId,
      createdAt: _now,
      updatedAt: _now,
    );

ServiceCategoryEntity _categoryEntity(String code,
        {String id = 'cat-1', String name = 'Cat'}) =>
    ServiceCategoryEntity(
        id: id, code: code, name: name, createdAt: _now, updatedAt: _now);

RepairServiceEntity _repairService({
  String id = 'svc-1',
  required String categoryId,
  required String modelId,
  DateTime? createdAt,
  String? createdBy,
  List<RepairServiceVariantEntity> variants = const [],
}) =>
    RepairServiceEntity(
      id: id,
      categoryId: categoryId,
      modelId: modelId,
      name: 'Old name',
      variants: variants,
      createdAt: createdAt ?? _now,
      updatedAt: _now,
      createdBy: createdBy,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(_manufacturer('x'));
    registerFallbackValue(_family('x', 'y'));
    registerFallbackValue(_modelEntity('x', 'y'));
    registerFallbackValue(_categoryEntity('x'));
    registerFallbackValue(_repairService(categoryId: 'x', modelId: 'y'));
    registerFallbackValue(const RepairServiceFilter());
  });

  late _MockManufacturerRepository manufacturerRepo;
  late _MockProductFamilyRepository familyRepo;
  late _MockModelRepository modelRepo;
  late _MockServiceCategoryRepository categoryRepo;
  late _MockRepairServiceRepository serviceRepo;
  late CatalogImportService service;

  setUp(() {
    manufacturerRepo = _MockManufacturerRepository();
    familyRepo = _MockProductFamilyRepository();
    modelRepo = _MockModelRepository();
    categoryRepo = _MockServiceCategoryRepository();
    serviceRepo = _MockRepairServiceRepository();
    service = CatalogImportService(
      manufacturerRepository: manufacturerRepo,
      productFamilyRepository: familyRepo,
      modelRepository: modelRepo,
      serviceCategoryRepository: categoryRepo,
      repairServiceRepository: serviceRepo,
    );
  });

  group('createMissingModels', () {
    const canonical = CanonicalModel(
      shorthand: 'X',
      modelCode: 'iphone_x',
      modelName: 'iPhone X',
      manufacturerCode: 'apple',
      manufacturerName: 'Apple',
      familyCode: 'iphone',
      familyName: 'iPhone',
    );

    test('creates manufacturer, family, and model from scratch when none exist',
        () async {
      when(() => manufacturerRepo.createManufacturer(any())).thenAnswer(
          (_) async => Right(_manufacturer('apple', id: 'new-mfr')));
      when(() => familyRepo.createProductFamily(any())).thenAnswer(
          (_) async => Right(_family('iphone', 'new-mfr', id: 'new-family')));
      when(() => modelRepo.createModel(any())).thenAnswer((_) async =>
          Right(_modelEntity('iphone_x', 'new-family', id: 'new-model')));

      final result = await service.createMissingModels(
        missingModels: const [canonical],
        snapshot: const CatalogAuditSnapshot(
          manufacturers: [],
          productFamilies: [],
          models: [],
          serviceCategories: [],
        ),
        createdBy: 'system_import',
      );

      expect(result.isRight(), isTrue);
      final models = result.getOrElse(() => []);
      expect(models.single.id, 'new-model');
      verify(() => manufacturerRepo.createManufacturer(any())).called(1);
      verify(() => familyRepo.createProductFamily(any())).called(1);
      verify(() => modelRepo.createModel(any())).called(1);
    });

    test(
        'reuses an existing manufacturer/family by code instead of creating duplicates',
        () async {
      final existingManufacturer = _manufacturer('apple', id: 'existing-mfr');
      final existingFamily =
          _family('iphone', 'existing-mfr', id: 'existing-family');

      when(() => modelRepo.createModel(any())).thenAnswer((_) async =>
          Right(_modelEntity('iphone_x', 'existing-family', id: 'new-model')));

      final result = await service.createMissingModels(
        missingModels: const [canonical],
        snapshot: CatalogAuditSnapshot(
          manufacturers: [existingManufacturer],
          productFamilies: [existingFamily],
          models: const [],
          serviceCategories: const [],
        ),
        createdBy: 'system_import',
      );

      expect(result.isRight(), isTrue);
      verifyNever(() => manufacturerRepo.createManufacturer(any()));
      verifyNever(() => familyRepo.createProductFamily(any()));
      verify(() => modelRepo.createModel(any())).called(1);
    });
  });

  group('importCategories — idempotent create vs update', () {
    final categories = productionServiceCategories.take(2).toList();

    test('creates categories that do not exist yet', () async {
      when(() => categoryRepo.createServiceCategory(any())).thenAnswer(
        (i) async => Right(_categoryEntity(
          (i.positionalArguments.first as ServiceCategoryEntity).code,
          id: 'new-${(i.positionalArguments.first as ServiceCategoryEntity).code}',
        )),
      );

      final result = await service.importCategories(
        categories: categories,
        existing: const [],
        createdBy: 'system_import',
      );

      final outcome =
          result.getOrElse(() => throw StateError('expected Right'));
      expect(outcome.created, 2);
      expect(outcome.updated, 0);
      expect(outcome.idByCode, {
        categories[0].code: 'new-${categories[0].code}',
        categories[1].code: 'new-${categories[1].code}',
      });
    });

    test(
        'updates a category that already exists (matched by code), preserving its id',
        () async {
      final existing =
          _categoryEntity(categories[0].code, id: 'live-id', name: 'Old Name');
      when(() => categoryRepo.updateServiceCategory(any())).thenAnswer(
          (i) async =>
              Right(i.positionalArguments.first as ServiceCategoryEntity));
      when(() => categoryRepo.createServiceCategory(any())).thenAnswer(
        (i) async => Right(_categoryEntity(
          (i.positionalArguments.first as ServiceCategoryEntity).code,
          id: 'new-id',
        )),
      );

      final result = await service.importCategories(
        categories: categories,
        existing: [existing],
        createdBy: 'system_import',
      );

      final outcome =
          result.getOrElse(() => throw StateError('expected Right'));
      expect(outcome.created, 1); // only categories[1] is new
      expect(outcome.updated, 1); // categories[0] already existed
      expect(outcome.idByCode[categories[0].code],
          'live-id'); // id preserved, not regenerated
      verifyNever(() => categoryRepo.createServiceCategory(
            any(
                that: predicate((e) =>
                    (e as ServiceCategoryEntity).code == categories[0].code)),
          ));
    });

    test('rerunning import a second time never creates a duplicate category',
        () async {
      final alreadyImported = [
        for (final def in categories)
          _categoryEntity(def.code, id: 'id-${def.code}'),
      ];
      when(() => categoryRepo.updateServiceCategory(any())).thenAnswer(
          (i) async =>
              Right(i.positionalArguments.first as ServiceCategoryEntity));

      final result = await service.importCategories(
        categories: categories,
        existing: alreadyImported,
        createdBy: 'system_import',
      );

      final outcome =
          result.getOrElse(() => throw StateError('expected Right'));
      expect(outcome.created, 0);
      expect(outcome.updated, 2);
      verifyNever(() => categoryRepo.createServiceCategory(any()));
    });
  });

  group('importServices — idempotent create vs update by (categoryId, modelId)',
      () {
    final row = ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: 'X',
      variants: const [
        VariantImportRow(
            code: 'battery_pisen', name: 'Pin Pisen', price: 500000)
      ],
    );

    test(
        'creates a new repair_services document when none matches (categoryId, modelId)',
        () async {
      when(() => serviceRepo.getRepairServices(any())).thenAnswer(
          (_) async => const Right(PaginatedResult(items: [], hasMore: false)));
      when(() => serviceRepo.createRepairService(any())).thenAnswer((i) async =>
          Right(i.positionalArguments.first as RepairServiceEntity));

      final result = await service.importServices(
        rows: [row],
        categoryIdByCode: {catPinIphone: 'cat-1'},
        categoryNameByCode: {catPinIphone: 'Pin iPhone'},
        modelIdByShorthand: {'X': 'model-1'},
        modelNameByShorthand: {'X': 'iPhone X'},
        createdBy: 'system_import',
      );

      final outcome =
          result.getOrElse(() => throw StateError('expected Right'));
      expect(outcome.created, 1);
      expect(outcome.updated, 0);

      final captured =
          verify(() => serviceRepo.createRepairService(captureAny()))
              .captured
              .single as RepairServiceEntity;
      expect(captured.name, 'Pin iPhone — iPhone X');
      expect(captured.variants.single.price, 500000);
    });

    test(
        'assigns order from list position — the price table\'s listing order survives import, never all-zero',
        () async {
      final multiVariantRow = ServiceImportRow(
        categoryCode: catPinIphone,
        modelShorthand: 'XS',
        variants: const [
          VariantImportRow(
              code: 'cell_zin_1_1',
              name: 'Cell zin 1:1',
              price: 250000,
              addons: [
                AddonImportRow(code: 'a1', name: 'A1', price: 0),
                AddonImportRow(code: 'a2', name: 'A2', price: 10000),
              ]),
          VariantImportRow(
              code: 'battery_pisen', name: 'Pin Pisen', price: 505000),
        ],
      );
      when(() => serviceRepo.getRepairServices(any())).thenAnswer(
          (_) async => const Right(PaginatedResult(items: [], hasMore: false)));
      when(() => serviceRepo.createRepairService(any())).thenAnswer((i) async =>
          Right(i.positionalArguments.first as RepairServiceEntity));

      await service.importServices(
        rows: [multiVariantRow],
        categoryIdByCode: {catPinIphone: 'cat-1'},
        categoryNameByCode: {catPinIphone: 'Pin iPhone'},
        modelIdByShorthand: {'XS': 'model-1'},
        modelNameByShorthand: {'XS': 'iPhone XS'},
        createdBy: 'system_import',
      );

      final captured =
          verify(() => serviceRepo.createRepairService(captureAny()))
              .captured
              .single as RepairServiceEntity;
      expect(captured.variants[0].order, 0);
      expect(captured.variants[1].order, 10);
      expect(captured.variants[0].addons[0].order, 0);
      expect(captured.variants[0].addons[1].order, 10);
    });

    test(
        'updates the existing document (found by categoryId+modelId), preserving createdAt/createdBy',
        () async {
      final createdAt = DateTime(2025, 3, 1);
      final existing = _repairService(
        id: 'existing-svc',
        categoryId: 'cat-1',
        modelId: 'model-1',
        createdAt: createdAt,
        createdBy: 'original-admin',
      );
      when(() => serviceRepo.getRepairServices(any())).thenAnswer((_) async =>
          Right(PaginatedResult(items: [existing], hasMore: false)));
      when(() => serviceRepo.updateRepairService(any())).thenAnswer((i) async =>
          Right(i.positionalArguments.first as RepairServiceEntity));

      final result = await service.importServices(
        rows: [row],
        categoryIdByCode: {catPinIphone: 'cat-1'},
        categoryNameByCode: {catPinIphone: 'Pin iPhone'},
        modelIdByShorthand: {'X': 'model-1'},
        modelNameByShorthand: {'X': 'iPhone X'},
        createdBy: 'system_import', // a different actor reruns the import
      );

      final outcome =
          result.getOrElse(() => throw StateError('expected Right'));
      expect(outcome.created, 0);
      expect(outcome.updated, 1);
      verifyNever(() => serviceRepo.createRepairService(any()));

      final captured =
          verify(() => serviceRepo.updateRepairService(captureAny()))
              .captured
              .single as RepairServiceEntity;
      expect(captured.id, 'existing-svc');
      expect(captured.createdAt, createdAt); // preserved, not reset
      expect(
          captured.createdBy, 'original-admin'); // preserved, not overwritten
      expect(captured.variants.single.price, 500000); // price refreshed
    });

    test(
        'a rerun over the full dataset never duplicates: second call still finds the first',
        () async {
      RepairServiceEntity? stored;
      when(() => serviceRepo.getRepairServices(any())).thenAnswer(
        (_) async => Right(PaginatedResult(
            items: stored == null ? [] : [stored!], hasMore: false)),
      );
      when(() => serviceRepo.createRepairService(any())).thenAnswer((i) async {
        stored = i.positionalArguments.first as RepairServiceEntity;
        return Right(stored!);
      });
      when(() => serviceRepo.updateRepairService(any())).thenAnswer((i) async {
        stored = i.positionalArguments.first as RepairServiceEntity;
        return Right(stored!);
      });

      final args = (
        rows: [row],
        categoryIdByCode: {catPinIphone: 'cat-1'},
        categoryNameByCode: {catPinIphone: 'Pin iPhone'},
        modelIdByShorthand: {'X': 'model-1'},
        modelNameByShorthand: {'X': 'iPhone X'},
      );

      final first = await service.importServices(
        rows: args.rows,
        categoryIdByCode: args.categoryIdByCode,
        categoryNameByCode: args.categoryNameByCode,
        modelIdByShorthand: args.modelIdByShorthand,
        modelNameByShorthand: args.modelNameByShorthand,
        createdBy: 'system_import',
      );
      final second = await service.importServices(
        rows: args.rows,
        categoryIdByCode: args.categoryIdByCode,
        categoryNameByCode: args.categoryNameByCode,
        modelIdByShorthand: args.modelIdByShorthand,
        modelNameByShorthand: args.modelNameByShorthand,
        createdBy: 'system_import',
      );

      expect(first.getOrElse(() => throw StateError('x')).created, 1);
      expect(second.getOrElse(() => throw StateError('x')).created, 0);
      expect(second.getOrElse(() => throw StateError('x')).updated, 1);
      verify(() => serviceRepo.createRepairService(any())).called(1);
    });
  });

  group('verify', () {
    final row = ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: 'X',
      variants: const [
        VariantImportRow(
            code: 'battery_pisen', name: 'Pin Pisen', price: 500000),
      ],
    );

    test('reports no mismatches when live data matches the dataset exactly',
        () async {
      final live = _repairService(
        categoryId: 'cat-1',
        modelId: 'model-1',
        variants: const [
          RepairServiceVariantEntity(
              code: 'battery_pisen', name: 'Pin Pisen', price: 500000),
        ],
      );
      when(() => serviceRepo.getRepairServices(any())).thenAnswer(
          (_) async => Right(PaginatedResult(items: [live], hasMore: false)));

      final report = await service.verify(
        rows: [row],
        categoryIdByCode: {catPinIphone: 'cat-1'},
        modelIdByShorthand: {'X': 'model-1'},
      );

      expect(report.isClean, isTrue);
      expect(report.recordsChecked, 1);
    });

    test('flags a price mismatch with expected vs actual', () async {
      final live = _repairService(
        categoryId: 'cat-1',
        modelId: 'model-1',
        variants: const [
          RepairServiceVariantEntity(
              code: 'battery_pisen', name: 'Pin Pisen', price: 999999),
        ],
      );
      when(() => serviceRepo.getRepairServices(any())).thenAnswer(
          (_) async => Right(PaginatedResult(items: [live], hasMore: false)));

      final report = await service.verify(
        rows: [row],
        categoryIdByCode: {catPinIphone: 'cat-1'},
        modelIdByShorthand: {'X': 'model-1'},
      );

      expect(report.isClean, isFalse);
      expect(report.priceMismatches.single.expectedPrice, 500000);
      expect(report.priceMismatches.single.actualPrice, 999999);
    });

    test('flags a missing document as mismatches for every one of its variants',
        () async {
      when(() => serviceRepo.getRepairServices(any())).thenAnswer(
          (_) async => const Right(PaginatedResult(items: [], hasMore: false)));

      final report = await service.verify(
        rows: [row],
        categoryIdByCode: {catPinIphone: 'cat-1'},
        modelIdByShorthand: {'X': 'model-1'},
      );

      expect(report.priceMismatches.single.actualPrice, isNull);
    });

    test('flags a service that is not booking-ready', () async {
      final disabled = _repairService(
        categoryId: 'cat-1',
        modelId: 'model-1',
        variants: const [
          RepairServiceVariantEntity(
              code: 'battery_pisen',
              name: 'Pin Pisen',
              price: 500000,
              enabled: false),
        ],
      );
      when(() => serviceRepo.getRepairServices(any())).thenAnswer((_) async =>
          Right(PaginatedResult(items: [disabled], hasMore: false)));

      final report = await service.verify(
        rows: [row],
        categoryIdByCode: {catPinIphone: 'cat-1'},
        modelIdByShorthand: {'X': 'model-1'},
      );

      expect(report.notBookingReady, isNotEmpty);
    });
  });
}
