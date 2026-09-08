import 'canonical_model_catalog.dart';
import 'production_catalog_dataset.dart';
import 'service_category_defs.dart';

/// A fully-offline summary of the Phase 3 production dataset — every count
/// derived from source, never hardcoded. Used both by the CMS Data Tools
/// "static dataset summary" panel (no Firestore needed) and by
/// `production_dataset_preflight_test.dart` to catch a future dataset edit
/// that becomes internally inconsistent.
class DatasetPreflightSummary {
  final int canonicalModelCount;
  final Map<String, int> canonicalByFamily;

  /// Unique models actually referenced by [productionServiceImportRows] —
  /// the set the import gate must resolve 100%, not [canonicalModelCount].
  final int requiredModelCount;
  final List<CanonicalModel> unusedCanonicalModels;

  final int categoryCount;
  final int serviceRowCount;
  final int variantCount;
  final int addonCount;
  final List<String> zeroPriceVariants;
  final List<String> zeroPriceAddons;
  final int negativePriceCount;
  final int duplicateCategoryCodes;
  final int duplicateCategoryModelMappings;
  final int rowsWithDuplicateVariantCodes;
  final int variantsWithDuplicateAddonCodes;
  final Map<String, ({int services, int variants, int addons})> perCategory;

  const DatasetPreflightSummary({
    required this.canonicalModelCount,
    required this.canonicalByFamily,
    required this.requiredModelCount,
    required this.unusedCanonicalModels,
    required this.categoryCount,
    required this.serviceRowCount,
    required this.variantCount,
    required this.addonCount,
    required this.zeroPriceVariants,
    required this.zeroPriceAddons,
    required this.negativePriceCount,
    required this.duplicateCategoryCodes,
    required this.duplicateCategoryModelMappings,
    required this.rowsWithDuplicateVariantCodes,
    required this.variantsWithDuplicateAddonCodes,
    required this.perCategory,
  });

  /// True only when the dataset is internally consistent — no negative
  /// prices, no duplicates on any dimension, and exactly 14 categories.
  /// Does NOT depend on Firestore/live model resolution in any way.
  bool get isClean =>
      negativePriceCount == 0 &&
      duplicateCategoryCodes == 0 &&
      duplicateCategoryModelMappings == 0 &&
      rowsWithDuplicateVariantCodes == 0 &&
      variantsWithDuplicateAddonCodes == 0 &&
      categoryCount == 14;

  /// Plain-text rendering suitable for a "copy result" button — no
  /// credentials, no live data, just the static dataset facts.
  String toPlainText() {
    final buffer = StringBuffer()
      ..writeln('Dataset FixShop 2026-08')
      ..writeln()
      ..writeln(
          'Models required: $requiredModelCount (canonical catalog: $canonicalModelCount)')
      ..writeln('Categories: $categoryCount')
      ..writeln('Services: $serviceRowCount')
      ..writeln('Variants: $variantCount')
      ..writeln('Add-ons: $addonCount (zero-price: ${zeroPriceAddons.length})')
      ..writeln()
      ..writeln('Dataset validation: ${isClean ? 'PASS' : 'FAIL'}');
    if (!isClean) {
      buffer
        ..writeln('  negative prices: $negativePriceCount')
        ..writeln('  duplicate category codes: $duplicateCategoryCodes')
        ..writeln(
            '  duplicate (category, model) mappings: $duplicateCategoryModelMappings')
        ..writeln(
            '  rows with duplicate variant codes: $rowsWithDuplicateVariantCodes')
        ..writeln(
            '  variants with duplicate addon codes: $variantsWithDuplicateAddonCodes');
    }
    return buffer.toString();
  }
}

DatasetPreflightSummary computeDatasetPreflightSummary() {
  final byFamily = <String, int>{};
  for (final m in canonicalModelCatalog) {
    byFamily[m.familyCode] = (byFamily[m.familyCode] ?? 0) + 1;
  }

  final uniqueShorthands =
      productionServiceImportRows.map((r) => r.modelShorthand).toSet();
  final unused = canonicalModelCatalog
      .where((m) => !uniqueShorthands.contains(m.shorthand))
      .toList();

  final variantCount =
      productionServiceImportRows.fold<int>(0, (s, r) => s + r.variants.length);
  final addonCount = productionServiceImportRows.fold<int>(
    0,
    (s, r) => s + r.variants.fold<int>(0, (s2, v) => s2 + v.addons.length),
  );

  final zeroPriceVariants = <String>[];
  final zeroPriceAddons = <String>[];
  var negativePriceCount = 0;
  for (final row in productionServiceImportRows) {
    for (final v in row.variants) {
      if (v.price == 0)
        zeroPriceVariants
            .add('${row.categoryCode}/${row.modelShorthand}/${v.code}');
      if (v.price < 0) negativePriceCount++;
      for (final a in v.addons) {
        if (a.price == 0) {
          zeroPriceAddons.add(
              '${row.categoryCode}/${row.modelShorthand}/${v.code}/${a.code}');
        }
        if (a.price < 0) negativePriceCount++;
      }
    }
  }

  final catCodes = productionServiceCategories.map((c) => c.code).toList();
  final duplicateCategoryCodes = catCodes.length - catCodes.toSet().length;

  final mappingKeys = productionServiceImportRows
      .map((r) => '${r.categoryCode}::${r.modelShorthand}')
      .toList();
  final duplicateCategoryModelMappings =
      mappingKeys.length - mappingKeys.toSet().length;

  var rowsWithDuplicateVariantCodes = 0;
  var variantsWithDuplicateAddonCodes = 0;
  for (final row in productionServiceImportRows) {
    final vcodes = row.variants.map((v) => v.code).toList();
    if (vcodes.toSet().length != vcodes.length) rowsWithDuplicateVariantCodes++;
    for (final v in row.variants) {
      final acodes = v.addons.map((a) => a.code).toList();
      if (acodes.toSet().length != acodes.length)
        variantsWithDuplicateAddonCodes++;
    }
  }

  final perCategory = <String, ({int services, int variants, int addons})>{};
  for (final cat in productionServiceCategories) {
    final rows = productionServiceImportRows
        .where((r) => r.categoryCode == cat.code)
        .toList();
    final vC = rows.fold<int>(0, (s, r) => s + r.variants.length);
    final aC = rows.fold<int>(
      0,
      (s, r) => s + r.variants.fold<int>(0, (s2, v) => s2 + v.addons.length),
    );
    perCategory[cat.code] = (services: rows.length, variants: vC, addons: aC);
  }

  return DatasetPreflightSummary(
    canonicalModelCount: canonicalModelCatalog.length,
    canonicalByFamily: byFamily,
    requiredModelCount: uniqueShorthands.length,
    unusedCanonicalModels: unused,
    categoryCount: productionServiceCategories.length,
    serviceRowCount: productionServiceImportRows.length,
    variantCount: variantCount,
    addonCount: addonCount,
    zeroPriceVariants: zeroPriceVariants,
    zeroPriceAddons: zeroPriceAddons,
    negativePriceCount: negativePriceCount,
    duplicateCategoryCodes: duplicateCategoryCodes,
    duplicateCategoryModelMappings: duplicateCategoryModelMappings,
    rowsWithDuplicateVariantCodes: rowsWithDuplicateVariantCodes,
    variantsWithDuplicateAddonCodes: variantsWithDuplicateAddonCodes,
    perCategory: perCategory,
  );
}
