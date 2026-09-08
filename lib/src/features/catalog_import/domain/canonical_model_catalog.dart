import 'package:equatable/equatable.dart';

/// One canonically-named device model the FixShop production price list
/// references, keyed by the shorthand token used in the source dataset
/// (e.g. `"13PROMAX"`, `"MINI 6"`, `"SERI 9"`, `"FOLD 5"`).
///
/// This is pure data — canonicalization never happens in customer UI or CMS
/// form code (Phase 1/2 audit requirement); it lives here, in the
/// migration/import layer, and nowhere else.
class CanonicalModel extends Equatable {
  /// The exact shorthand token as it appears in the production price list.
  final String shorthand;

  /// Deterministic, human-reviewable model code — reused as `models.code`
  /// when a matching model doesn't already exist in the live catalog.
  final String modelCode;

  /// Canonical display name, e.g. "iPhone 13 Pro Max".
  final String modelName;

  final String manufacturerCode;
  final String manufacturerName;
  final String familyCode;
  final String familyName;

  const CanonicalModel({
    required this.shorthand,
    required this.modelCode,
    required this.modelName,
    required this.manufacturerCode,
    required this.manufacturerName,
    required this.familyCode,
    required this.familyName,
  });

  @override
  List<Object?> get props => [
        shorthand,
        modelCode,
        modelName,
        manufacturerCode,
        manufacturerName,
        familyCode,
        familyName,
      ];
}

const _apple = ('apple', 'Apple');
const _samsung = ('samsung', 'Samsung');

CanonicalModel _iphone(String shorthand, String code, String name) =>
    CanonicalModel(
      shorthand: shorthand,
      modelCode: 'iphone_$code',
      modelName: name,
      manufacturerCode: _apple.$1,
      manufacturerName: _apple.$2,
      familyCode: 'iphone',
      familyName: 'iPhone',
    );

CanonicalModel _ipad(String shorthand, String code, String name) =>
    CanonicalModel(
      shorthand: shorthand,
      modelCode: 'ipad_$code',
      modelName: name,
      manufacturerCode: _apple.$1,
      manufacturerName: _apple.$2,
      familyCode: 'ipad',
      familyName: 'iPad',
    );

CanonicalModel _airpods(String shorthand, String code, String name) =>
    CanonicalModel(
      shorthand: shorthand,
      modelCode: 'airpods_$code',
      modelName: name,
      manufacturerCode: _apple.$1,
      manufacturerName: _apple.$2,
      familyCode: 'airpods',
      familyName: 'AirPods',
    );

CanonicalModel _watch(String shorthand, String code, String name) =>
    CanonicalModel(
      shorthand: shorthand,
      modelCode: 'apple_watch_$code',
      modelName: name,
      manufacturerCode: _apple.$1,
      manufacturerName: _apple.$2,
      familyCode: 'apple_watch',
      familyName: 'Apple Watch',
    );

CanonicalModel _galaxyZFlip(String shorthand, String code, String name) =>
    CanonicalModel(
      shorthand: shorthand,
      modelCode: 'galaxy_z_flip_$code',
      modelName: name,
      manufacturerCode: _samsung.$1,
      manufacturerName: _samsung.$2,
      familyCode: 'galaxy_z_flip',
      familyName: 'Galaxy Z Flip',
    );

CanonicalModel _galaxyZFold(String shorthand, String code, String name) =>
    CanonicalModel(
      shorthand: shorthand,
      modelCode: 'galaxy_z_fold_$code',
      modelName: name,
      manufacturerCode: _samsung.$1,
      manufacturerName: _samsung.$2,
      familyCode: 'galaxy_z_fold',
      familyName: 'Galaxy Z Fold',
    );

final List<CanonicalModel> _iphoneModels = [
  _iphone('6', '6', 'iPhone 6'),
  _iphone('6S', '6s', 'iPhone 6s'),
  _iphone('6P', '6_plus', 'iPhone 6 Plus'),
  _iphone('6SP', '6s_plus', 'iPhone 6s Plus'),
  _iphone('7', '7', 'iPhone 7'),
  _iphone('7P', '7_plus', 'iPhone 7 Plus'),
  _iphone('8', '8', 'iPhone 8'),
  _iphone('8P', '8_plus', 'iPhone 8 Plus'),
  _iphone('X', 'x', 'iPhone X'),
  _iphone('XS', 'xs', 'iPhone XS'),
  _iphone('XR', 'xr', 'iPhone XR'),
  _iphone('XMAX', 'xs_max', 'iPhone XS Max'),
  _iphone('11', '11', 'iPhone 11'),
  _iphone('11PRO', '11_pro', 'iPhone 11 Pro'),
  _iphone('11PROMAX', '11_pro_max', 'iPhone 11 Pro Max'),
  _iphone('12MINI', '12_mini', 'iPhone 12 mini'),
  _iphone('12', '12', 'iPhone 12'),
  _iphone('12PRO', '12_pro', 'iPhone 12 Pro'),
  _iphone('12PROMAX', '12_pro_max', 'iPhone 12 Pro Max'),
  _iphone('13MINI', '13_mini', 'iPhone 13 mini'),
  _iphone('13', '13', 'iPhone 13'),
  _iphone('13PRO', '13_pro', 'iPhone 13 Pro'),
  _iphone('13PROMAX', '13_pro_max', 'iPhone 13 Pro Max'),
  _iphone('14', '14', 'iPhone 14'),
  _iphone('14PLUS', '14_plus', 'iPhone 14 Plus'),
  _iphone('14PRO', '14_pro', 'iPhone 14 Pro'),
  _iphone('14PROMAX', '14_pro_max', 'iPhone 14 Pro Max'),
  _iphone('15', '15', 'iPhone 15'),
  _iphone('15PLUS', '15_plus', 'iPhone 15 Plus'),
  _iphone('15PRO', '15_pro', 'iPhone 15 Pro'),
  _iphone('15PROMAX', '15_pro_max', 'iPhone 15 Pro Max'),
];

final List<CanonicalModel> _ipadModels = [
  _ipad('MINI4', 'mini_4', 'iPad mini 4'),
  _ipad('MINI5', 'mini_5', 'iPad mini 5'),
  _ipad('MINI6', 'mini_6', 'iPad mini 6'),
  _ipad('AIR1', 'air_1', 'iPad Air 1'),
  _ipad('AIR2', 'air_2', 'iPad Air 2'),
  _ipad('AIR3', 'air_3', 'iPad Air 3'),
  _ipad('AIR4', 'air_4', 'iPad Air 4'),
  _ipad('AIR5', 'air_5', 'iPad Air 5'),
  _ipad('GEN5', 'gen_5', 'iPad Gen 5'),
  _ipad('GEN6', 'gen_6', 'iPad Gen 6'),
  _ipad('GEN7', 'gen_7', 'iPad Gen 7'),
  _ipad('GEN8', 'gen_8', 'iPad Gen 8'),
  _ipad('GEN9', 'gen_9', 'iPad Gen 9'),
  _ipad('GEN10', 'gen_10', 'iPad Gen 10'),
  _ipad('PRO97', 'pro_97', 'iPad Pro 9.7-inch'),
  _ipad('PRO105', 'pro_105', 'iPad Pro 10.5-inch'),
  _ipad('PRO11_2018', 'pro_11_2018', 'iPad Pro 11-inch (2018)'),
  _ipad('PRO11_2020', 'pro_11_2020', 'iPad Pro 11-inch (2020)'),
  _ipad('PRO11_2021', 'pro_11_2021', 'iPad Pro 11-inch (2021)'),
  _ipad('PRO11_2021_M1', 'pro_11_2021_m1', 'iPad Pro 11-inch (2021, M1)'),
  _ipad('PRO11_2022', 'pro_11_2022', 'iPad Pro 11-inch (2022)'),
  _ipad('PRO129_2015', 'pro_129_2015', 'iPad Pro 12.9-inch (2015)'),
  _ipad('PRO129_2017', 'pro_129_2017', 'iPad Pro 12.9-inch (2017)'),
  _ipad('PRO129_2018', 'pro_129_2018', 'iPad Pro 12.9-inch (2018)'),
  _ipad('PRO129_2020', 'pro_129_2020', 'iPad Pro 12.9-inch (2020)'),
  _ipad('PRO129_2021', 'pro_129_2021', 'iPad Pro 12.9-inch (2021)'),
  _ipad('PRO129_2021_M1', 'pro_129_2021_m1', 'iPad Pro 12.9-inch (2021, M1)'),
  _ipad('PRO129_2022', 'pro_129_2022', 'iPad Pro 12.9-inch (2022)'),
];

final List<CanonicalModel> _airpodsModels = [
  _airpods('AIRPODS1', '1', 'AirPods 1'),
  _airpods('AIRPODS2', '2', 'AirPods 2'),
  _airpods('AIRPODS3', '3', 'AirPods 3'),
  _airpods('AIRPODS4', '4', 'AirPods 4'),
  _airpods('AIRPODSPRO1', 'pro_1', 'AirPods Pro 1'),
  _airpods('AIRPODSPRO2', 'pro_2', 'AirPods Pro 2'),
];

final List<CanonicalModel> _appleWatchModels = [
  _watch('WATCH2', 'series_2', 'Apple Watch Series 2'),
  _watch('WATCH3', 'series_3', 'Apple Watch Series 3'),
  _watch('WATCH4', 'series_4', 'Apple Watch Series 4'),
  _watch('WATCH5', 'series_5', 'Apple Watch Series 5'),
  _watch('WATCH6', 'series_6', 'Apple Watch Series 6'),
  _watch('WATCH7', 'series_7', 'Apple Watch Series 7'),
  _watch('WATCH8', 'series_8', 'Apple Watch Series 8'),
  _watch('WATCH9', 'series_9', 'Apple Watch Series 9'),
  _watch('WATCH10', 'series_10', 'Apple Watch Series 10'),
  _watch('WATCHSE', 'se', 'Apple Watch SE'),
  _watch('WATCHULTRA1', 'ultra_1', 'Apple Watch Ultra 1'),
  _watch('WATCHULTRA2', 'ultra_2', 'Apple Watch Ultra 2'),
];

final List<CanonicalModel> _samsungModels = [
  _galaxyZFlip('FLIP1', '1', 'Samsung Galaxy Z Flip 1'),
  _galaxyZFlip('FLIP2', '2', 'Samsung Galaxy Z Flip 2'),
  _galaxyZFlip('FLIP3', '3', 'Samsung Galaxy Z Flip 3'),
  _galaxyZFlip('FLIP4', '4', 'Samsung Galaxy Z Flip 4'),
  _galaxyZFlip('FLIP5', '5', 'Samsung Galaxy Z Flip 5'),
  _galaxyZFold('FOLD1', '1', 'Samsung Galaxy Z Fold 1'),
  _galaxyZFold('FOLD2', '2', 'Samsung Galaxy Z Fold 2'),
  _galaxyZFold('FOLD3', '3', 'Samsung Galaxy Z Fold 3'),
  _galaxyZFold('FOLD4', '4', 'Samsung Galaxy Z Fold 4'),
  _galaxyZFold('FOLD5', '5', 'Samsung Galaxy Z Fold 5'),
];

/// Every model shorthand the Phase 3 production dataset references, mapped
/// to its canonical name and catalog hierarchy placement. See Phase 3
/// spec sections 3-7 — this is a direct, reviewable transcription of that
/// mapping table, nothing inferred or invented.
final List<CanonicalModel> canonicalModelCatalog = [
  ..._iphoneModels,
  ..._ipadModels,
  ..._airpodsModels,
  ..._appleWatchModels,
  ..._samsungModels,
];

/// Lookup by shorthand — the dataset's join key.
final Map<String, CanonicalModel> canonicalModelByShorthand = {
  for (final m in canonicalModelCatalog) m.shorthand: m,
};

/// The subset of [canonicalModelCatalog] actually referenced by
/// [requiredShorthands] — this is the list the production import gate must
/// resolve 100%, NOT the full canonical catalog. A canonical model with no
/// production service row (e.g. a device generation the current price list
/// simply has no pricing for yet) must never block import just because it
/// happens to exist in this mapping table.
List<CanonicalModel> requiredCanonicalModels(
    Iterable<String> requiredShorthands) {
  final needed = requiredShorthands.toSet();
  return canonicalModelCatalog
      .where((m) => needed.contains(m.shorthand))
      .toList();
}
