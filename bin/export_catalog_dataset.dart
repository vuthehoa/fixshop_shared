// Dumps the authoritative production catalog dataset to JSON on stdout.
//
// This is the SINGLE source of truth for the reset/import/verify tooling in
// fixshop_cms/tools/catalog-reset — that tooling must never re-transcribe
// prices, only read this export. Regenerate with:
//
//   cd fixshop_shared
//   dart run bin/export_catalog_dataset.dart > ../fixshop_cms/tools/catalog-reset/catalog_dataset.json
//
// Pure Dart (no Flutter imports) so `dart run` works without a device.
//
// ignore_for_file: avoid_print, avoid_relative_lib_imports
import 'dart:convert';

import '../lib/src/features/catalog_import/domain/canonical_model_catalog.dart';
import '../lib/src/features/catalog_import/domain/production_catalog_dataset.dart';
import '../lib/src/features/catalog_import/domain/service_category_defs.dart';

void main() {
  final requiredShorthands =
      productionServiceImportRows.map((r) => r.modelShorthand).toSet();

  final out = <String, dynamic>{
    'source': 'fixshop_shared/lib/src/features/catalog_import/domain/'
        'production_catalog_dataset.dart',
    'importVersion': '2026-08',
    'currency': 'VND',
    'categories': [
      for (final c in productionServiceCategories)
        {
          'code': c.code,
          'name': c.name,
          'order': c.order,
          'enabled': true,
          'status': 'active',
        },
    ],
    'services': [
      for (final row in productionServiceImportRows)
        {
          'categoryCode': row.categoryCode,
          'modelShorthand': row.modelShorthand,
          'variants': [
            for (final v in row.variants)
              {
                'code': v.code,
                'name': v.name,
                'customerDisplayName': v.customerDisplayName,
                'price': v.price,
                'addons': [
                  for (final a in v.addons)
                    {'code': a.code, 'name': a.name, 'price': a.price},
                ],
              },
          ],
        },
    ],
    'canonicalModels': [
      for (final m in canonicalModelCatalog)
        {
          'shorthand': m.shorthand,
          'modelCode': m.modelCode,
          'modelName': m.modelName,
          'manufacturerCode': m.manufacturerCode,
          'manufacturerName': m.manufacturerName,
          'familyCode': m.familyCode,
          'familyName': m.familyName,
        },
    ],
    'requiredShorthands': requiredShorthands.toList()..sort(),
    'counts': {
      'categories': productionServiceCategories.length,
      'services': productionServiceImportRows.length,
      'variants': productionServiceImportRows.fold<int>(
          0, (s, r) => s + r.variants.length),
      'addons': productionServiceImportRows.fold<int>(
          0,
          (s, r) =>
              s + r.variants.fold<int>(0, (s2, v) => s2 + v.addons.length)),
      'requiredModels': requiredShorthands.length,
      'canonicalModels': canonicalModelCatalog.length,
    },
  };

  print(const JsonEncoder.withIndent('  ').convert(out));
}
