import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:flutter_test/flutter_test.dart';

ModelEntity _model(String code, {CatalogStatus status = CatalogStatus.active}) {
  final now = DateTime(2026, 1, 1);
  return ModelEntity(
    id: 'id-$code',
    code: code,
    name: code,
    productFamilyId: 'family-1',
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('resolveModels', () {
    test('resolves every canonical model that already exists live, by code',
        () {
      final result = resolveModels(
        canonicalModels: canonicalModelCatalog,
        existingModels:
            canonicalModelCatalog.map((c) => _model(c.modelCode)).toList(),
      );

      expect(result.isComplete, isTrue);
      expect(result.resolvedModelIds.length, canonicalModelCatalog.length);
      expect(result.missingModels, isEmpty);
    });

    test('reports missing models when the live catalog has none of them', () {
      final result = resolveModels(
          canonicalModels: canonicalModelCatalog, existingModels: const []);

      expect(result.isComplete, isFalse);
      expect(result.missingModels.length, canonicalModelCatalog.length);
      expect(result.resolvedModelIds, isEmpty);
    });

    test(
        'a partially-populated catalog resolves only what exists, flags the rest',
        () {
      const iphone13ProMax = CanonicalModel(
        shorthand: '13PROMAX',
        modelCode: 'iphone_13_pro_max',
        modelName: 'iPhone 13 Pro Max',
        manufacturerCode: 'apple',
        manufacturerName: 'Apple',
        familyCode: 'iphone',
        familyName: 'iPhone',
      );
      const galaxyZFold5 = CanonicalModel(
        shorthand: 'FOLD5',
        modelCode: 'galaxy_z_fold_5',
        modelName: 'Samsung Galaxy Z Fold 5',
        manufacturerCode: 'samsung',
        manufacturerName: 'Samsung',
        familyCode: 'galaxy_z_fold',
        familyName: 'Galaxy Z Fold',
      );

      final result = resolveModels(
        canonicalModels: [iphone13ProMax, galaxyZFold5],
        existingModels: [_model('iphone_13_pro_max')],
      );

      expect(result.resolvedModelIds, {'13PROMAX': 'id-iphone_13_pro_max'});
      expect(result.missingModels, [galaxyZFold5]);
    });

    test('archived models still resolve (audit reads all statuses)', () {
      const model = CanonicalModel(
        shorthand: 'X',
        modelCode: 'iphone_x',
        modelName: 'iPhone X',
        manufacturerCode: 'apple',
        manufacturerName: 'Apple',
        familyCode: 'iphone',
        familyName: 'iPhone',
      );
      final result = resolveModels(
        canonicalModels: [model],
        existingModels: [_model('iphone_x', status: CatalogStatus.archived)],
      );
      expect(result.isComplete, isTrue);
    });
  });

  group('validateDataset', () {
    const category =
        ServiceCategoryDef(code: 'cat_a', name: 'Category A', order: 10);

    test('a clean 14-category dataset with unique mappings passes', () {
      final result = validateDataset(
        categories: productionServiceCategories,
        rows: productionServiceImportRows,
      );
      expect(result.isValid, isTrue, reason: result.errors.join('\n'));
    });

    test('fewer than 14 categories fails validation', () {
      final result = validateDataset(categories: [category], rows: const []);
      expect(result.isValid, isFalse);
      expect(result.errors, contains(contains('exactly 14')));
    });

    test('duplicate category codes are rejected', () {
      final result = validateDataset(
        categories: [category, category],
        rows: const [],
      );
      expect(result.errors, contains(contains('Duplicate category code')));
    });

    test('a row referencing an unknown category code is rejected', () {
      final result = validateDataset(
        categories: [category],
        rows: const [
          ServiceImportRow(
            categoryCode: 'unknown_cat',
            modelShorthand: 'X',
            variants: [VariantImportRow(code: 'v1', name: 'V1', price: 100)],
          ),
        ],
      );
      expect(result.errors, contains(contains('unknown category code')));
    });

    test('duplicate (categoryCode, modelShorthand) pairs are rejected', () {
      final rows = [
        const ServiceImportRow(
          categoryCode: 'cat_a',
          modelShorthand: 'X',
          variants: [VariantImportRow(code: 'v1', name: 'V1', price: 100)],
        ),
        const ServiceImportRow(
          categoryCode: 'cat_a',
          modelShorthand: 'X',
          variants: [VariantImportRow(code: 'v2', name: 'V2', price: 200)],
        ),
      ];
      final result = validateDataset(categories: [category], rows: rows);
      expect(result.errors,
          contains(contains('Duplicate (categoryCode, modelShorthand)')));
    });

    test('a row with zero variants is rejected', () {
      final result = validateDataset(
        categories: [category],
        rows: const [
          ServiceImportRow(
              categoryCode: 'cat_a', modelShorthand: 'X', variants: []),
        ],
      );
      expect(result.errors, contains(contains('zero variants')));
    });

    test('price = 0 passes validation — never treated as invalid', () {
      final result = validateDataset(
        categories: [category],
        rows: const [
          ServiceImportRow(
            categoryCode: 'cat_a',
            modelShorthand: 'X',
            variants: [VariantImportRow(code: 'v1', name: 'V1', price: 0)],
          ),
        ],
      );
      // Only the (unrelated) "must have 14 categories" error is expected —
      // nothing about the price=0 row itself should be flagged.
      expect(result.errors.where((e) => e.toLowerCase().contains('price')),
          isEmpty);
    });

    test('a negative variant price is rejected', () {
      final result = validateDataset(
        categories: [category],
        rows: const [
          ServiceImportRow(
            categoryCode: 'cat_a',
            modelShorthand: 'X',
            variants: [VariantImportRow(code: 'v1', name: 'V1', price: -1)],
          ),
        ],
      );
      expect(result.errors, contains(contains('Negative price')));
    });

    test('a negative addon price is rejected', () {
      final result = validateDataset(
        categories: [category],
        rows: const [
          ServiceImportRow(
            categoryCode: 'cat_a',
            modelShorthand: 'X',
            variants: [
              VariantImportRow(
                code: 'v1',
                name: 'V1',
                price: 100,
                addons: [AddonImportRow(code: 'a1', name: 'A1', price: -50)],
              ),
            ],
          ),
        ],
      );
      expect(result.errors, contains(contains('addon')));
    });

    test('duplicate variant codes within one row are rejected', () {
      final result = validateDataset(
        categories: [category],
        rows: const [
          ServiceImportRow(
            categoryCode: 'cat_a',
            modelShorthand: 'X',
            variants: [
              VariantImportRow(code: 'v1', name: 'V1', price: 100),
              VariantImportRow(code: 'v1', name: 'V1 dup', price: 200),
            ],
          ),
        ],
      );
      expect(result.errors, contains(contains('Duplicate variant code')));
    });

    test('duplicate addon codes within one variant are rejected', () {
      final result = validateDataset(
        categories: [category],
        rows: const [
          ServiceImportRow(
            categoryCode: 'cat_a',
            modelShorthand: 'X',
            variants: [
              VariantImportRow(
                code: 'v1',
                name: 'V1',
                price: 100,
                addons: [
                  AddonImportRow(code: 'a1', name: 'A1', price: 0),
                  AddonImportRow(code: 'a1', name: 'A1 dup', price: 50),
                ],
              ),
            ],
          ),
        ],
      );
      expect(result.errors, contains(contains('Duplicate addon code')));
    });
  });

  group('buildDryRunReport', () {
    test('a dry-run with no missing models and no validation errors can import',
        () {
      final resolution = resolveModels(
        canonicalModels: canonicalModelCatalog,
        existingModels:
            canonicalModelCatalog.map((c) => _model(c.modelCode)).toList(),
      );
      final report = buildDryRunReport(
        categories: productionServiceCategories,
        rows: productionServiceImportRows,
        modelResolution: resolution,
        existingCategories: const [],
      );

      expect(report.canImport, isTrue);
      expect(report.categoryCount, 14);
      expect(report.serviceCount, productionServiceImportRows.length);
      expect(report.missingModels, isEmpty);
      expect(report.validationErrors, isEmpty);
    });

    test(
        'dry-run with missing models cannot import, even if the dataset is otherwise valid',
        () {
      final resolution = resolveModels(
          canonicalModels: canonicalModelCatalog, existingModels: const []);
      final report = buildDryRunReport(
        categories: productionServiceCategories,
        rows: productionServiceImportRows,
        modelResolution: resolution,
        existingCategories: const [],
      );

      expect(report.canImport, isFalse);
      expect(report.missingModels, isNotEmpty);
    });

    test('counts variants and addons correctly', () {
      final rows = [
        const ServiceImportRow(
          categoryCode: 'cat_a',
          modelShorthand: 'X',
          variants: [
            VariantImportRow(
              code: 'v1',
              name: 'V1',
              price: 100,
              addons: [AddonImportRow(code: 'a1', name: 'A1', price: 0)],
            ),
            VariantImportRow(code: 'v2', name: 'V2', price: 200),
          ],
        ),
      ];
      final report = buildDryRunReport(
        categories: const [
          ServiceCategoryDef(code: 'cat_a', name: 'A', order: 10)
        ],
        rows: rows,
        modelResolution:
            const ModelResolution(resolvedModelIds: {}, missingModels: []),
        existingCategories: const [],
      );

      expect(report.serviceCount, 1);
      expect(report.variantCount, 2);
      expect(report.addonCount, 1);
    });
  });
}
