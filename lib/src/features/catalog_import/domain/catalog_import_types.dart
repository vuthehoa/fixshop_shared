import 'package:equatable/equatable.dart';

import 'canonical_model_catalog.dart';

/// Result of matching every [CanonicalModel] the dataset references against
/// the live `models` collection (matched by `model.code`).
class ModelResolution extends Equatable {
  /// shorthand → live Firestore model id.
  final Map<String, String> resolvedModelIds;

  /// Canonical models with no matching live `models` document — these must
  /// be created (Manufacturer → ProductFamily → Model) before import can
  /// proceed, unless the caller explicitly allows missing models.
  final List<CanonicalModel> missingModels;

  const ModelResolution({
    required this.resolvedModelIds,
    required this.missingModels,
  });

  bool get isComplete => missingModels.isEmpty;

  @override
  List<Object?> get props => [resolvedModelIds, missingModels];
}

/// Pure dataset-shape validation — no Firestore access. See Phase 3 spec
/// section 30.
class DatasetValidationResult extends Equatable {
  final List<String> errors;

  const DatasetValidationResult(this.errors);

  bool get isValid => errors.isEmpty;

  @override
  List<Object?> get props => [errors];
}

/// Everything a dry-run must report before any write is attempted. See
/// Phase 3 spec section 28.
class DryRunReport extends Equatable {
  final int categoryCount;
  final int serviceCount;
  final int variantCount;
  final int addonCount;
  final List<CanonicalModel> missingModels;
  final List<String> validationErrors;

  const DryRunReport({
    required this.categoryCount,
    required this.serviceCount,
    required this.variantCount,
    required this.addonCount,
    required this.missingModels,
    required this.validationErrors,
  });

  /// True only when the dataset is 100% valid AND every referenced model
  /// resolves against the live catalog — the sole condition under which
  /// [CatalogImportService.import] is allowed to write anything.
  bool get canImport => validationErrors.isEmpty && missingModels.isEmpty;

  @override
  List<Object?> get props => [
        categoryCount,
        serviceCount,
        variantCount,
        addonCount,
        missingModels,
        validationErrors
      ];
}

/// Outcome of an actual write pass.
class ImportResult extends Equatable {
  final int categoriesCreated;
  final int categoriesUpdated;
  final int modelsCreated;
  final int servicesCreated;
  final int servicesUpdated;

  const ImportResult({
    required this.categoriesCreated,
    required this.categoriesUpdated,
    required this.modelsCreated,
    required this.servicesCreated,
    required this.servicesUpdated,
  });

  @override
  List<Object?> get props => [
        categoriesCreated,
        categoriesUpdated,
        modelsCreated,
        servicesCreated,
        servicesUpdated
      ];
}

/// One price mismatch found while re-reading Firestore after import and
/// comparing it against the source dataset.
class PriceMismatch extends Equatable {
  final String categoryCode;
  final String modelShorthand;
  final String variantCode;
  final String? addonCode; // null when the mismatch is on the variant itself
  final int expectedPrice;
  final int? actualPrice; // null when the variant/addon is entirely missing

  const PriceMismatch({
    required this.categoryCode,
    required this.modelShorthand,
    required this.variantCode,
    this.addonCode,
    required this.expectedPrice,
    this.actualPrice,
  });

  @override
  String toString() => '$categoryCode/$modelShorthand/$variantCode'
      '${addonCode == null ? '' : '/$addonCode'}: '
      'expected=$expectedPrice actual=${actualPrice ?? "MISSING"}';

  @override
  List<Object?> get props => [
        categoryCode,
        modelShorthand,
        variantCode,
        addonCode,
        expectedPrice,
        actualPrice
      ];
}

/// Full post-import verification result. See Phase 3 spec sections 42-46.
class VerifyReport extends Equatable {
  final int recordsChecked;
  final List<PriceMismatch> priceMismatches;
  final List<String> duplicateCategoryCodes;
  final List<String> duplicateMappings; // "categoryId::modelId"
  final List<String> orphanServices; // services with unresolved category/model
  final List<String>
      notBookingReady; // imported services failing isBookingReady

  const VerifyReport({
    required this.recordsChecked,
    required this.priceMismatches,
    required this.duplicateCategoryCodes,
    required this.duplicateMappings,
    required this.orphanServices,
    required this.notBookingReady,
  });

  bool get isClean =>
      priceMismatches.isEmpty &&
      duplicateCategoryCodes.isEmpty &&
      duplicateMappings.isEmpty &&
      orphanServices.isEmpty &&
      notBookingReady.isEmpty;

  @override
  List<Object?> get props => [
        recordsChecked,
        priceMismatches,
        duplicateCategoryCodes,
        duplicateMappings,
        orphanServices,
        notBookingReady,
      ];
}
