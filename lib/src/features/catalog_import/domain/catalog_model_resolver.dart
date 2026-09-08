import '../../model/domain/entities/model_entity.dart';
import '../../service_category/domain/entities/service_category_entity.dart';
import 'canonical_model_catalog.dart';
import 'catalog_import_types.dart';
import 'service_category_defs.dart';
import 'service_import_row.dart';

/// Matches every [CanonicalModel] against a live snapshot of `models`
/// (matched by `model.code`, the deterministic key this migration owns —
/// see Phase 3 spec section 38: reuse an existing model's code if the live
/// catalog already has one, never rename it).
///
/// Pure function — no Firestore access, fully unit-testable.
ModelResolution resolveModels({
  required List<CanonicalModel> canonicalModels,
  required List<ModelEntity> existingModels,
}) {
  final byCode = {for (final m in existingModels) m.code: m.id};

  final resolved = <String, String>{};
  final missing = <CanonicalModel>[];
  for (final canonical in canonicalModels) {
    final id = byCode[canonical.modelCode];
    if (id != null) {
      resolved[canonical.shorthand] = id;
    } else {
      missing.add(canonical);
    }
  }
  return ModelResolution(resolvedModelIds: resolved, missingModels: missing);
}

/// Pure, Firestore-free validation of the dataset's *shape* — see Phase 3
/// spec section 30. Does not check model resolution (that's
/// [resolveModels]'s job) or live-catalog uniqueness (that's checked
/// against the fetched snapshot by the caller); this only checks internal
/// consistency of the source dataset itself.
DatasetValidationResult validateDataset({
  required List<ServiceCategoryDef> categories,
  required List<ServiceImportRow> rows,
}) {
  final errors = <String>[];

  if (categories.length != 14) {
    errors.add(
        'Expected exactly 14 service categories, found ${categories.length}.');
  }

  final categoryCodes = <String>{};
  for (final c in categories) {
    if (!categoryCodes.add(c.code)) {
      errors.add('Duplicate category code: ${c.code}');
    }
    if (c.order < 0) {
      errors.add('Category "${c.code}" has a negative order: ${c.order}');
    }
  }

  final validCategoryCodes = categories.map((c) => c.code).toSet();
  final seenMappings = <String>{};

  for (final row in rows) {
    if (!validCategoryCodes.contains(row.categoryCode)) {
      errors.add('Row references unknown category code: ${row.categoryCode}');
    }

    final mappingKey = '${row.categoryCode}::${row.modelShorthand}';
    if (!seenMappings.add(mappingKey)) {
      errors.add('Duplicate (categoryCode, modelShorthand) pair: $mappingKey');
    }

    if (row.variants.isEmpty) {
      errors.add('Row $mappingKey has zero variants.');
    }

    final variantCodes = <String>{};
    for (final v in row.variants) {
      if (!variantCodes.add(v.code)) {
        errors
            .add('Duplicate variant code "${v.code}" within row $mappingKey.');
      }
      if (v.price < 0) {
        errors.add(
            'Negative price for variant "${v.code}" in row $mappingKey: ${v.price}');
      }

      final addonCodes = <String>{};
      for (final a in v.addons) {
        if (!addonCodes.add(a.code)) {
          errors.add(
            'Duplicate addon code "${a.code}" within variant "${v.code}" (row $mappingKey).',
          );
        }
        if (a.price < 0) {
          errors.add(
            'Negative price for addon "${a.code}" in variant "${v.code}" (row $mappingKey): ${a.price}',
          );
        }
      }
    }
  }

  return DatasetValidationResult(errors);
}

/// Checks the dataset's category codes against categories that already
/// exist live (by `code`) with a *different* code casing/spelling is not a
/// concern here — this only flags categories the live catalog already has
/// under a conflicting definition, which should never happen since codes
/// are the shared join key, but is checked anyway per Phase 3 spec section 30.
List<String> validateNoConflictingLiveCategories({
  required List<ServiceCategoryDef> categories,
  required List<ServiceCategoryEntity> existingCategories,
}) {
  final existingByCode = {for (final c in existingCategories) c.code: c};
  final errors = <String>[];
  for (final def in categories) {
    final existing = existingByCode[def.code];
    if (existing != null && existing.name != def.name) {
      errors.add(
        'Category code "${def.code}" already exists live with a different name '
        '("${existing.name}" vs dataset "${def.name}") — resolve manually before import.',
      );
    }
  }
  return errors;
}

/// Builds the full pre-write report — combines dataset validation with live
/// model resolution and dataset counts. See Phase 3 spec section 28.
DryRunReport buildDryRunReport({
  required List<ServiceCategoryDef> categories,
  required List<ServiceImportRow> rows,
  required ModelResolution modelResolution,
  required List<ServiceCategoryEntity> existingCategories,
}) {
  final datasetValidation = validateDataset(categories: categories, rows: rows);
  final conflictErrors = validateNoConflictingLiveCategories(
    categories: categories,
    existingCategories: existingCategories,
  );

  final variantCount = rows.fold<int>(0, (sum, r) => sum + r.variants.length);
  final addonCount = rows.fold<int>(
    0,
    (sum, r) => sum + r.variants.fold<int>(0, (s, v) => s + v.addons.length),
  );

  return DryRunReport(
    categoryCount: categories.length,
    serviceCount: rows.length,
    variantCount: variantCount,
    addonCount: addonCount,
    missingModels: modelResolution.missingModels,
    validationErrors: [...datasetValidation.errors, ...conflictErrors],
  );
}
