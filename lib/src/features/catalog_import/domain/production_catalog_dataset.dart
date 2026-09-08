/// FixShop production repair-service price list — the single source of
/// truth for Phase 3 import. Direct, line-by-line transcription of the
/// production dataset supplied for this phase; every row here maps to one
/// row in that source. Numbers only (never formatted strings); rows for
/// "-" / blank cells are omitted entirely rather than encoded as a price.
///
/// source = "FixShop production price list"
/// importVersion = "2026-08"
library;

import 'service_category_defs.dart';
import 'service_import_row.dart';

ServiceImportRow _single(
  String categoryCode,
  String modelShorthand,
  String variantCode,
  String variantName,
  int price, {
  List<AddonImportRow> addons = const [],
}) {
  return ServiceImportRow(
    categoryCode: categoryCode,
    modelShorthand: modelShorthand,
    variants: [
      VariantImportRow(
        code: variantCode,
        name: variantName,
        price: price,
        addons: addons,
      ),
    ],
  );
}

// ── 1. Ép kính iPhone ───────────────────────────────────────────────────
final List<ServiceImportRow> _glassReplacementIphone = [
  _single(catEpKinhIphone, 'X', 'glass_replacement', 'Ép kính', 280000),
  _single(catEpKinhIphone, 'XS', 'glass_replacement', 'Ép kính', 250000),
  _single(catEpKinhIphone, 'XR', 'glass_replacement', 'Ép kính', 250000),
  _single(catEpKinhIphone, 'XMAX', 'glass_replacement', 'Ép kính', 300000),
  _single(catEpKinhIphone, '11', 'glass_replacement', 'Ép kính', 250000),
  _single(catEpKinhIphone, '11PRO', 'glass_replacement', 'Ép kính', 250000),
  _single(catEpKinhIphone, '11PROMAX', 'glass_replacement', 'Ép kính', 400000),
  _single(catEpKinhIphone, '12MINI', 'glass_replacement', 'Ép kính', 300000),
  _single(catEpKinhIphone, '12', 'glass_replacement', 'Ép kính', 400000),
  _single(catEpKinhIphone, '12PRO', 'glass_replacement', 'Ép kính', 400000),
  _single(catEpKinhIphone, '12PROMAX', 'glass_replacement', 'Ép kính', 400000),
  _single(catEpKinhIphone, '13MINI', 'glass_replacement', 'Ép kính', 400000),
  _single(catEpKinhIphone, '13', 'glass_replacement', 'Ép kính', 400000),
  _single(catEpKinhIphone, '13PRO', 'glass_replacement', 'Ép kính', 500000),
  _single(catEpKinhIphone, '13PROMAX', 'glass_replacement', 'Ép kính', 500000),
  _single(catEpKinhIphone, '14', 'glass_replacement', 'Ép kính', 500000),
  _single(catEpKinhIphone, '14PLUS', 'glass_replacement', 'Ép kính', 500000),
  _single(catEpKinhIphone, '14PRO', 'glass_replacement', 'Ép kính', 600000),
  _single(catEpKinhIphone, '14PROMAX', 'glass_replacement', 'Ép kính', 600000),
  _single(catEpKinhIphone, '15', 'glass_replacement', 'Ép kính', 600000),
  _single(catEpKinhIphone, '15PLUS', 'glass_replacement', 'Ép kính', 600000),
  _single(catEpKinhIphone, '15PRO', 'glass_replacement', 'Ép kính', 800000),
  _single(catEpKinhIphone, '15PROMAX', 'glass_replacement', 'Ép kính', 800000),
];

// ── 2. Face ID ──────────────────────────────────────────────────────────
VariantImportRow _trueDepth(int p) =>
    VariantImportRow(code: 'truedepth', name: 'TrueDepth', price: p);
VariantImportRow _cbCable(int p) =>
    VariantImportRow(code: 'cb_cable', name: 'Dây CB', price: p);

final List<ServiceImportRow> _faceId = [
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: 'X',
      variants: [_trueDepth(200000), _cbCable(200000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: 'XS',
      variants: [_trueDepth(200000), _cbCable(200000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: 'XR',
      variants: [_trueDepth(200000), _cbCable(200000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: 'XMAX',
      variants: [_trueDepth(200000), _cbCable(200000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '11',
      variants: [_trueDepth(200000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '11PRO',
      variants: [_trueDepth(200000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '11PROMAX',
      variants: [_trueDepth(200000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '12MINI',
      variants: [_trueDepth(200000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '12',
      variants: [_trueDepth(200000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '12PRO',
      variants: [_trueDepth(200000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '12PROMAX',
      variants: [_trueDepth(200000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '13MINI',
      variants: [_trueDepth(600000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '13',
      variants: [_trueDepth(600000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '13PRO',
      variants: [_trueDepth(600000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '13PROMAX',
      variants: [_trueDepth(600000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '14',
      variants: [_trueDepth(600000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '14PLUS',
      variants: [_trueDepth(600000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '14PRO',
      variants: [_trueDepth(600000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '14PROMAX',
      variants: [_trueDepth(600000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '15',
      variants: [_trueDepth(600000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '15PLUS',
      variants: [_trueDepth(600000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '15PRO',
      variants: [_trueDepth(800000)]),
  ServiceImportRow(
      categoryCode: catFaceId,
      modelShorthand: '15PROMAX',
      variants: [_trueDepth(800000)]),
];

// ── 3. Ép cảm ứng iPhone ────────────────────────────────────────────────
final List<ServiceImportRow> _touchRepairIphone = [
  _single(catEpCamUngIphone, 'X', 'ch_full', 'CH - Full', 350000),
  _single(catEpCamUngIphone, 'XS', 'ch_full', 'CH - Full', 350000),
  _single(catEpCamUngIphone, 'XR', 'ch_full', 'CH - Full', 350000),
  _single(catEpCamUngIphone, 'XMAX', 'ch_full', 'CH - Full', 450000),
  _single(catEpCamUngIphone, '11', 'ch_full', 'CH - Full', 500000),
  _single(catEpCamUngIphone, '11PRO', 'ch_full', 'CH - Full', 500000),
  _single(catEpCamUngIphone, '11PROMAX', 'ch_full', 'CH - Full', 600000),
  _single(catEpCamUngIphone, '12MINI', 'ch_full', 'CH - Full', 700000),
  _single(catEpCamUngIphone, '12', 'ch_full', 'CH - Full', 600000),
  _single(catEpCamUngIphone, '12PRO', 'ch_full', 'CH - Full', 600000),
  _single(catEpCamUngIphone, '12PROMAX', 'ch_full', 'CH - Full', 900000),
  _single(catEpCamUngIphone, '13PROMAX', 'ch_full', 'CH - Full', 1400000),
];

// ── 4. Giá màn iPhone ───────────────────────────────────────────────────
final List<ServiceImportRow> _screenReplacementIphone = [
  _single(catGiaManIphone, 'X', 'ek_screen', 'Màn EK', 1100000),
  _single(catGiaManIphone, 'XS', 'ek_screen', 'Màn EK', 1100000),
  _single(catGiaManIphone, 'XR', 'ek_screen', 'Màn EK', 650000),
  _single(catGiaManIphone, 'XMAX', 'ek_screen', 'Màn EK', 1900000),
  _single(catGiaManIphone, '11', 'ek_screen', 'Màn EK', 800000),
  _single(catGiaManIphone, '11PRO', 'ek_screen', 'Màn EK', 1300000),
  _single(catGiaManIphone, '11PROMAX', 'ek_screen', 'Màn EK', 1900000),
  _single(catGiaManIphone, '12MINI', 'ek_screen', 'Màn EK', 1900000),
  _single(catGiaManIphone, '12', 'ek_screen', 'Màn EK', 2100000),
  _single(catGiaManIphone, '12PRO', 'ek_screen', 'Màn EK', 2100000),
  _single(catGiaManIphone, '12PROMAX', 'ek_screen', 'Màn EK', 3300000),
  _single(catGiaManIphone, '13MINI', 'ek_screen', 'Màn EK', 2100000),
  _single(catGiaManIphone, '13', 'ek_screen', 'Màn EK', 2500000),
  _single(catGiaManIphone, '13PRO', 'ek_screen', 'Màn EK', 3700000),
  _single(catGiaManIphone, '13PROMAX', 'ek_screen', 'Màn EK', 4200000),
  _single(catGiaManIphone, '14', 'ek_screen', 'Màn EK', 2200000),
  _single(catGiaManIphone, '14PLUS', 'ek_screen', 'Màn EK', 3300000),
  _single(catGiaManIphone, '14PRO', 'ek_screen', 'Màn EK', 5200000),
  _single(catGiaManIphone, '14PROMAX', 'ek_screen', 'Màn EK', 7500000),
  _single(catGiaManIphone, '15', 'ek_screen', 'Màn EK', 2100000),
  _single(catGiaManIphone, '15PLUS', 'ek_screen', 'Màn EK', 3300000),
  _single(catGiaManIphone, '15PRO', 'ek_screen', 'Màn EK', 5800000),
  _single(catGiaManIphone, '15PROMAX', 'ek_screen', 'Màn EK', 8500000),
];

// ── 5. Pin AirPods ──────────────────────────────────────────────────────
final List<ServiceImportRow> _airpodsBattery = [
  ServiceImportRow(
      categoryCode: catPinAirpods,
      modelShorthand: 'AIRPODS1',
      variants: [
        const VariantImportRow(
            code: 'ear_battery', name: 'Pin tai', price: 200000),
        const VariantImportRow(
            code: 'connection_issue', name: 'Lỗi kết nối', price: 300000),
      ]),
  ServiceImportRow(
      categoryCode: catPinAirpods,
      modelShorthand: 'AIRPODS2',
      variants: [
        const VariantImportRow(
            code: 'ear_battery', name: 'Pin tai', price: 200000),
        const VariantImportRow(
            code: 'connection_issue', name: 'Lỗi kết nối', price: 300000),
      ]),
  ServiceImportRow(
      categoryCode: catPinAirpods,
      modelShorthand: 'AIRPODS3',
      variants: [
        const VariantImportRow(
            code: 'ear_battery', name: 'Pin tai', price: 300000),
        const VariantImportRow(
            code: 'connection_issue', name: 'Lỗi kết nối', price: 350000),
      ]),
  ServiceImportRow(
      categoryCode: catPinAirpods,
      modelShorthand: 'AIRPODS4',
      variants: [
        const VariantImportRow(
            code: 'ear_battery', name: 'Pin tai', price: 350000),
        const VariantImportRow(
            code: 'connection_issue', name: 'Lỗi kết nối', price: 400000),
      ]),
  ServiceImportRow(
      categoryCode: catPinAirpods,
      modelShorthand: 'AIRPODSPRO1',
      variants: [
        const VariantImportRow(
            code: 'ear_battery', name: 'Pin tai', price: 300000),
        const VariantImportRow(
            code: 'connection_issue', name: 'Lỗi kết nối', price: 350000),
      ]),
  ServiceImportRow(
      categoryCode: catPinAirpods,
      modelShorthand: 'AIRPODSPRO2',
      variants: [
        const VariantImportRow(
            code: 'ear_battery', name: 'Pin tai', price: 300000),
        const VariantImportRow(
            code: 'connection_issue', name: 'Lỗi kết nối', price: 350000),
      ]),
];

// ── 6. Pin iPhone ───────────────────────────────────────────────────────
// Note: 'cell_dlc' ("Cell DLC") is a defined variant code per the Phase 3
// spec's Pin iPhone variant list but has no production price rows in the
// current dataset — no helper for it since nothing would ever call it.
VariantImportRow _cellZin(int p) =>
    VariantImportRow(code: 'cell_zin_1_1', name: 'Cell zin 1:1', price: p);
VariantImportRow _cellEnergizer(int p) =>
    VariantImportRow(code: 'cell_energizer', name: 'Cell Energizer', price: p);
VariantImportRow _batteryFlex(int p) =>
    VariantImportRow(code: 'battery_with_flex', name: 'Pin có cổ', price: p);
VariantImportRow _batteryPisen(int p) =>
    VariantImportRow(code: 'battery_pisen', name: 'Pin Pisen', price: p);
VariantImportRow _batteryPisenDlc(int p) => VariantImportRow(
    code: 'battery_pisen_dlc', name: 'Pin Pisen DLC', price: p);
VariantImportRow _batteryEnergizer(int p) => VariantImportRow(
    code: 'battery_energizer', name: 'Pin Energizer', price: p);

final List<ServiceImportRow> _iphoneBattery = [
  ServiceImportRow(categoryCode: catPinIphone, modelShorthand: '6', variants: [
    _batteryPisen(275000),
  ]),
  ServiceImportRow(categoryCode: catPinIphone, modelShorthand: '6S', variants: [
    _batteryFlex(180000),
    _batteryPisen(275000),
  ]),
  ServiceImportRow(categoryCode: catPinIphone, modelShorthand: '6P', variants: [
    _batteryFlex(200000),
    _batteryPisen(325000),
  ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: '6SP',
      variants: [
        _batteryFlex(220000),
        _batteryPisen(325000),
        _batteryPisenDlc(495000),
      ]),
  ServiceImportRow(categoryCode: catPinIphone, modelShorthand: '7', variants: [
    _batteryFlex(160000),
    _batteryPisen(298000),
    _batteryPisenDlc(475000),
    _batteryEnergizer(535000),
  ]),
  ServiceImportRow(categoryCode: catPinIphone, modelShorthand: '7P', variants: [
    _batteryFlex(200000),
    _batteryPisen(330000),
    _batteryPisenDlc(520000),
    _batteryEnergizer(605000),
  ]),
  ServiceImportRow(categoryCode: catPinIphone, modelShorthand: '8', variants: [
    _batteryFlex(200000),
    _batteryPisen(335000),
    _batteryEnergizer(545000),
  ]),
  ServiceImportRow(categoryCode: catPinIphone, modelShorthand: '8P', variants: [
    _batteryFlex(200000),
    _batteryPisen(355000),
    _batteryEnergizer(610000),
  ]),
  ServiceImportRow(categoryCode: catPinIphone, modelShorthand: 'X', variants: [
    _batteryFlex(300000),
    _batteryPisen(500000),
    _batteryPisenDlc(520000),
    _batteryEnergizer(710000),
  ]),
  ServiceImportRow(categoryCode: catPinIphone, modelShorthand: 'XR', variants: [
    _cellZin(250000),
    _cellEnergizer(435000),
    _batteryFlex(300000),
    _batteryPisen(455000),
    _batteryEnergizer(660000),
  ]),
  ServiceImportRow(categoryCode: catPinIphone, modelShorthand: 'XS', variants: [
    _cellZin(250000),
    _cellEnergizer(705000),
    _batteryFlex(350000),
    _batteryPisen(505000),
    _batteryPisenDlc(520000),
    _batteryEnergizer(750000),
  ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: 'XMAX',
      variants: [
        _cellZin(300000),
        _cellEnergizer(510000),
        _batteryFlex(350000),
        _batteryPisen(525000),
        _batteryPisenDlc(545000),
        _batteryEnergizer(775000),
      ]),
  ServiceImportRow(categoryCode: catPinIphone, modelShorthand: '11', variants: [
    _cellZin(300000),
    _cellEnergizer(530000),
    _batteryFlex(350000),
    _batteryPisen(550000),
    _batteryPisenDlc(585000),
    _batteryEnergizer(815000),
  ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: '11PRO',
      variants: [
        _cellZin(300000),
        _cellEnergizer(535000),
        _batteryFlex(400000),
        _batteryPisen(670000),
        _batteryEnergizer(940000),
      ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: '11PROMAX',
      variants: [
        _cellZin(400000),
        _cellEnergizer(585000),
        _batteryFlex(450000),
        _batteryPisen(690000),
        _batteryPisenDlc(710000),
        _batteryEnergizer(985000),
      ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: '12MINI',
      variants: [
        _cellZin(300000),
        _batteryFlex(500000),
      ]),
  ServiceImportRow(categoryCode: catPinIphone, modelShorthand: '12', variants: [
    _cellZin(400000),
    _cellEnergizer(515000),
    _batteryFlex(450000),
    _batteryPisen(475000),
    _batteryPisenDlc(580000),
    _batteryEnergizer(840000),
  ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: '12PRO',
      variants: [
        _cellZin(400000),
        _cellEnergizer(515000),
        _batteryFlex(450000),
        _batteryPisen(475000),
        _batteryEnergizer(840000),
      ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: '12PROMAX',
      variants: [
        _cellZin(400000),
        _cellEnergizer(605000),
        _batteryFlex(500000),
        _batteryPisen(635000),
        _batteryEnergizer(1035000),
      ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: '13MINI',
      variants: [
        _cellZin(400000),
        _batteryFlex(550000),
      ]),
  ServiceImportRow(categoryCode: catPinIphone, modelShorthand: '13', variants: [
    _cellZin(400000),
    _cellEnergizer(530000),
    _batteryFlex(500000),
    _batteryPisen(480000),
    _batteryEnergizer(835000),
  ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: '13PRO',
      variants: [
        _cellZin(500000),
        _cellEnergizer(585000),
        _batteryFlex(500000),
        _batteryPisen(615000),
        _batteryEnergizer(1030000),
      ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: '13PROMAX',
      variants: [
        _cellZin(500000),
        _cellEnergizer(690000),
        _batteryFlex(550000),
        _batteryPisen(640000),
        _batteryEnergizer(1080000),
      ]),
  ServiceImportRow(categoryCode: catPinIphone, modelShorthand: '14', variants: [
    _cellZin(400000),
    _batteryFlex(600000),
  ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: '14PLUS',
      variants: [
        _cellZin(400000),
        _batteryFlex(600000),
      ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: '14PRO',
      variants: [
        _cellZin(600000),
        _cellEnergizer(685000),
        _batteryFlex(600000),
      ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: '14PROMAX',
      variants: [
        _cellZin(600000),
        _cellEnergizer(810000),
        _batteryFlex(650000),
        _batteryPisen(810000),
      ]),
  ServiceImportRow(categoryCode: catPinIphone, modelShorthand: '15', variants: [
    _cellZin(600000),
    _batteryFlex(600000),
  ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: '15PLUS',
      variants: [
        _cellZin(600000),
        _batteryFlex(650000),
      ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: '15PRO',
      variants: [
        _cellZin(600000),
        _batteryFlex(700000),
      ]),
  ServiceImportRow(
      categoryCode: catPinIphone,
      modelShorthand: '15PROMAX',
      variants: [
        _cellZin(600000),
        _batteryFlex(800000),
      ]),
];

// ── 7. Samsung Fold / Flip ──────────────────────────────────────────────
final List<ServiceImportRow> _samsungFoldFlip = [
  _single(catSamsungFoldFlip, 'FLIP1', 'flex_cable', 'Cáp', 500000),
  _single(catSamsungFoldFlip, 'FLIP2', 'flex_cable', 'Cáp', 600000),
  _single(catSamsungFoldFlip, 'FLIP3', 'flex_cable', 'Cáp', 700000),
  _single(catSamsungFoldFlip, 'FLIP4', 'flex_cable', 'Cáp', 900000),
  _single(catSamsungFoldFlip, 'FLIP5', 'flex_cable', 'Cáp', 1200000),
  _single(catSamsungFoldFlip, 'FOLD1', 'flex_cable', 'Cáp', 700000),
  _single(catSamsungFoldFlip, 'FOLD2', 'flex_cable', 'Cáp', 800000),
  _single(catSamsungFoldFlip, 'FOLD3', 'flex_cable', 'Cáp', 1200000),
  _single(catSamsungFoldFlip, 'FOLD4', 'flex_cable', 'Cáp', 1200000),
  _single(catSamsungFoldFlip, 'FOLD5', 'flex_cable', 'Cáp', 1500000),
];

// ── 8. Thay phôi pin iPhone ─────────────────────────────────────────────
const _fix3uTools = 'fix_3utools_duplicate';
const _fix3uToolsName = 'Fix trùng 3uTools';
const _cellReplace = 'battery_cell_replace_fix_health';
const _cellReplaceName = 'Thay phôi pin + fix % trong Cài đặt';

ServiceImportRow _cellReplaceRow(String model, int price, {int? addonPrice}) {
  return ServiceImportRow(
    categoryCode: catThayPhoiPin,
    modelShorthand: model,
    variants: [
      VariantImportRow(
        code: _cellReplace,
        name: _cellReplaceName,
        price: price,
        addons: addonPrice == null
            ? const []
            : [
                AddonImportRow(
                    code: _fix3uTools, name: _fix3uToolsName, price: addonPrice)
              ],
      ),
    ],
  );
}

final List<ServiceImportRow> _batteryCellReplacement = [
  // iPhone X không tạo service (per source).
  _cellReplaceRow('XS', 300000, addonPrice: 0),
  _cellReplaceRow('XR', 300000, addonPrice: 0),
  _cellReplaceRow('XMAX', 300000, addonPrice: 0),
  _cellReplaceRow('11', 300000, addonPrice: 120000),
  _cellReplaceRow('11PRO', 400000, addonPrice: 150000),
  _cellReplaceRow('11PROMAX', 400000, addonPrice: 150000),
  _cellReplaceRow('12MINI', 300000, addonPrice: 150000),
  _cellReplaceRow('12', 350000, addonPrice: 150000),
  _cellReplaceRow('12PRO', 350000, addonPrice: 150000),
  _cellReplaceRow('12PROMAX', 450000, addonPrice: 150000),
  _cellReplaceRow('13MINI', 350000, addonPrice: 180000),
  _cellReplaceRow('13', 400000, addonPrice: 180000),
  _cellReplaceRow('13PRO', 450000, addonPrice: 180000),
  _cellReplaceRow('13PROMAX', 500000, addonPrice: 180000),
  _cellReplaceRow('14', 400000, addonPrice: 180000),
  _cellReplaceRow('14PLUS', 450000, addonPrice: 180000),
  _cellReplaceRow('14PRO', 500000, addonPrice: 180000),
  _cellReplaceRow('14PROMAX', 500000, addonPrice: 180000),
  _cellReplaceRow('15', 500000),
  _cellReplaceRow('15PLUS', 500000),
  _cellReplaceRow('15PRO', 600000),
  _cellReplaceRow('15PROMAX', 600000),
];

// ── 9. Sửa camera sau iPhone ────────────────────────────────────────────
ServiceImportRow _rearCameraRow(
    String model, int spotCleaning, int lensReplacement, int stabilizationFocus,
    {int? errorFix}) {
  return ServiceImportRow(
    categoryCode: catCameraSau,
    modelShorthand: model,
    variants: [
      VariantImportRow(
          code: 'camera_spot_cleaning', name: 'Rửa đốm', price: spotCleaning),
      VariantImportRow(
          code: 'camera_lens_replacement',
          name: 'Thay thấu',
          price: lensReplacement),
      VariantImportRow(
          code: 'camera_stabilization_focus_fix',
          name: 'Fix rung / lấy nét',
          price: stabilizationFocus),
      if (errorFix != null)
        VariantImportRow(
            code: 'camera_error_fix', name: 'Fix báo', price: errorFix),
    ],
  );
}

final List<ServiceImportRow> _rearCameraRepair = [
  _rearCameraRow('X', 50000, 100000, 50000),
  _rearCameraRow('XS', 50000, 100000, 50000),
  _rearCameraRow('XR', 50000, 150000, 50000),
  _rearCameraRow('XMAX', 50000, 150000, 50000),
  _rearCameraRow('11', 50000, 150000, 50000),
  _rearCameraRow('11PRO', 50000, 150000, 50000),
  _rearCameraRow('11PROMAX', 50000, 150000, 100000),
  _rearCameraRow('12MINI', 60000, 150000, 100000, errorFix: 400000),
  _rearCameraRow('12', 60000, 150000, 100000, errorFix: 400000),
  _rearCameraRow('12PRO', 60000, 200000, 350000, errorFix: 400000),
  _rearCameraRow('12PROMAX', 60000, 300000, 350000, errorFix: 400000),
  _rearCameraRow('13MINI', 80000, 200000, 150000, errorFix: 400000),
  _rearCameraRow('13', 80000, 200000, 150000, errorFix: 400000),
  _rearCameraRow('13PRO', 80000, 300000, 300000, errorFix: 400000),
  _rearCameraRow('13PROMAX', 80000, 350000, 400000, errorFix: 400000),
  _rearCameraRow('14', 80000, 350000, 200000, errorFix: 400000),
  _rearCameraRow('14PLUS', 80000, 350000, 200000, errorFix: 400000),
  _rearCameraRow('14PRO', 90000, 350000, 300000, errorFix: 400000),
  _rearCameraRow('14PROMAX', 90000, 350000, 350000, errorFix: 400000),
  _rearCameraRow('15', 90000, 350000, 250000, errorFix: 400000),
  _rearCameraRow('15PLUS', 90000, 350000, 250000, errorFix: 400000),
  _rearCameraRow('15PRO', 100000, 350000, 300000, errorFix: 400000),
  _rearCameraRow('15PROMAX', 100000, 350000, 300000, errorFix: 400000),
];

// ── 10. Thay lưng iPhone ────────────────────────────────────────────────
ServiceImportRow _backGlassRow(String model,
    {int? largeCutout, int? smallCutout}) {
  return ServiceImportRow(
    categoryCode: catThayLung,
    modelShorthand: model,
    variants: [
      if (largeCutout != null)
        VariantImportRow(
            code: 'large_camera_cutout_back_glass',
            name: 'Mắt to',
            price: largeCutout),
      if (smallCutout != null)
        VariantImportRow(
            code: 'small_camera_cutout_back_glass',
            name: 'Mắt nhỏ',
            price: smallCutout),
    ],
  );
}

final List<ServiceImportRow> _backGlass = [
  _backGlassRow('X', largeCutout: 150000, smallCutout: 180000),
  _backGlassRow('XS', largeCutout: 150000, smallCutout: 200000),
  _backGlassRow('XR', largeCutout: 200000, smallCutout: 200000),
  _backGlassRow('XMAX', largeCutout: 180000, smallCutout: 220000),
  _backGlassRow('11', largeCutout: 200000, smallCutout: 200000),
  _backGlassRow('11PRO', largeCutout: 250000, smallCutout: 300000),
  _backGlassRow('11PROMAX', largeCutout: 250000, smallCutout: 350000),
  _backGlassRow('12MINI', largeCutout: 200000, smallCutout: 240000),
  _backGlassRow('12', largeCutout: 250000, smallCutout: 300000),
  _backGlassRow('12PRO', largeCutout: 300000, smallCutout: 400000),
  _backGlassRow('12PROMAX', largeCutout: 300000, smallCutout: 400000),
  _backGlassRow('13MINI', largeCutout: 300000, smallCutout: 350000),
  _backGlassRow('13', largeCutout: 300000, smallCutout: 350000),
  _backGlassRow('13PRO', largeCutout: 350000, smallCutout: 500000),
  _backGlassRow('13PROMAX', largeCutout: 500000, smallCutout: 600000),
  _backGlassRow('14', smallCutout: 350000), // large = "-"
  _backGlassRow('14PLUS', smallCutout: 400000),
  _backGlassRow('14PRO', largeCutout: 450000, smallCutout: 600000),
  _backGlassRow('14PROMAX', largeCutout: 450000, smallCutout: 600000),
  _backGlassRow('15', smallCutout: 400000),
  _backGlassRow('15PLUS', smallCutout: 550000),
  _backGlassRow('15PRO', smallCutout: 650000),
  _backGlassRow('15PROMAX', smallCutout: 700000),
];

// ── 11. Ép cảm ứng iPad ─────────────────────────────────────────────────
final List<ServiceImportRow> _touchRepairIpad = [
  _single(catEpCamUngIpad, 'MINI4', 'touch_replacement', 'Ép cảm ứng', 500000),
  _single(catEpCamUngIpad, 'MINI5', 'touch_replacement', 'Ép cảm ứng', 600000),
  _single(catEpCamUngIpad, 'MINI6', 'touch_replacement', 'Ép cảm ứng', 800000),
  _single(catEpCamUngIpad, 'AIR1', 'touch_replacement', 'Ép cảm ứng', 400000),
  _single(catEpCamUngIpad, 'AIR2', 'touch_replacement', 'Ép cảm ứng', 500000),
  _single(catEpCamUngIpad, 'AIR3', 'touch_replacement', 'Ép cảm ứng', 700000),
  _single(catEpCamUngIpad, 'AIR4', 'touch_replacement', 'Ép cảm ứng', 900000),
  _single(catEpCamUngIpad, 'AIR5', 'touch_replacement', 'Ép cảm ứng', 900000),
  _single(catEpCamUngIpad, 'PRO97', 'touch_replacement', 'Ép cảm ứng', 600000),
  _single(catEpCamUngIpad, 'PRO105', 'touch_replacement', 'Ép cảm ứng', 700000),
  _single(catEpCamUngIpad, 'PRO11_2018', 'touch_replacement', 'Ép cảm ứng',
      1200000),
  _single(catEpCamUngIpad, 'PRO11_2020', 'touch_replacement', 'Ép cảm ứng',
      1200000),
  _single(catEpCamUngIpad, 'PRO11_2021', 'touch_replacement', 'Ép cảm ứng',
      1500000),
  _single(catEpCamUngIpad, 'PRO11_2022', 'touch_replacement', 'Ép cảm ứng',
      1500000),
  _single(catEpCamUngIpad, 'PRO129_2015', 'touch_replacement', 'Ép cảm ứng',
      1200000),
  _single(catEpCamUngIpad, 'PRO129_2017', 'touch_replacement', 'Ép cảm ứng',
      1500000),
  _single(catEpCamUngIpad, 'PRO129_2018', 'touch_replacement', 'Ép cảm ứng',
      1600000),
  _single(catEpCamUngIpad, 'PRO129_2020', 'touch_replacement', 'Ép cảm ứng',
      1600000),
  _single(catEpCamUngIpad, 'PRO129_2021', 'touch_replacement', 'Ép cảm ứng',
      1800000),
  _single(catEpCamUngIpad, 'PRO129_2022', 'touch_replacement', 'Ép cảm ứng',
      1800000),
  _single(catEpCamUngIpad, 'GEN5', 'touch_replacement', 'Ép cảm ứng', 500000),
  _single(catEpCamUngIpad, 'GEN6', 'touch_replacement', 'Ép cảm ứng', 500000),
  _single(catEpCamUngIpad, 'GEN7', 'touch_replacement', 'Ép cảm ứng', 500000),
  _single(catEpCamUngIpad, 'GEN8', 'touch_replacement', 'Ép cảm ứng', 500000),
  _single(catEpCamUngIpad, 'GEN9', 'touch_replacement', 'Ép cảm ứng', 500000),
  _single(catEpCamUngIpad, 'GEN10', 'touch_replacement', 'Ép cảm ứng', 700000),
];

// ── 12. Pin iPad ────────────────────────────────────────────────────────
final List<ServiceImportRow> _ipadBattery = [
  _single(catPinIpad, 'MINI4', 'battery_replacement_ek', 'Thay pin', 300000),
  _single(catPinIpad, 'MINI5', 'battery_replacement_ek', 'Thay pin', 400000),
  _single(catPinIpad, 'MINI6', 'battery_replacement_ek', 'Thay pin', 500000),
  _single(catPinIpad, 'AIR1', 'battery_replacement_ek', 'Thay pin', 400000),
  _single(catPinIpad, 'AIR2', 'battery_replacement_ek', 'Thay pin', 400000),
  _single(catPinIpad, 'AIR3', 'battery_replacement_ek', 'Thay pin', 500000),
  _single(catPinIpad, 'AIR4', 'battery_replacement_ek', 'Thay pin', 700000),
  _single(catPinIpad, 'AIR5', 'battery_replacement_ek', 'Thay pin', 700000),
  _single(catPinIpad, 'PRO97', 'battery_replacement_ek', 'Thay pin', 500000),
  _single(catPinIpad, 'PRO105', 'battery_replacement_ek', 'Thay pin', 500000),
  _single(
      catPinIpad, 'PRO11_2018', 'battery_replacement_ek', 'Thay pin', 700000),
  _single(
      catPinIpad, 'PRO11_2020', 'battery_replacement_ek', 'Thay pin', 700000),
  _single(
      catPinIpad, 'PRO11_2021', 'battery_replacement_ek', 'Thay pin', 900000),
  _single(
      catPinIpad, 'PRO11_2022', 'battery_replacement_ek', 'Thay pin', 1000000),
  _single(
      catPinIpad, 'PRO129_2015', 'battery_replacement_ek', 'Thay pin', 700000),
  _single(
      catPinIpad, 'PRO129_2017', 'battery_replacement_ek', 'Thay pin', 900000),
  _single(
      catPinIpad, 'PRO129_2018', 'battery_replacement_ek', 'Thay pin', 1000000),
  _single(
      catPinIpad, 'PRO129_2020', 'battery_replacement_ek', 'Thay pin', 1000000),
  _single(
      catPinIpad, 'PRO129_2021', 'battery_replacement_ek', 'Thay pin', 1500000),
  _single(
      catPinIpad, 'PRO129_2022', 'battery_replacement_ek', 'Thay pin', 1500000),
  _single(catPinIpad, 'GEN5', 'battery_replacement_ek', 'Thay pin', 500000),
  _single(catPinIpad, 'GEN6', 'battery_replacement_ek', 'Thay pin', 500000),
  _single(catPinIpad, 'GEN7', 'battery_replacement_ek', 'Thay pin', 500000),
  _single(catPinIpad, 'GEN8', 'battery_replacement_ek', 'Thay pin', 500000),
  _single(catPinIpad, 'GEN9', 'battery_replacement_ek', 'Thay pin', 500000),
  _single(catPinIpad, 'GEN10', 'battery_replacement_ek', 'Thay pin', 700000),
];

// ── 13. Apple Watch ─────────────────────────────────────────────────────
ServiceImportRow _watchRow(String model, {int? glass, int? touch}) {
  return ServiceImportRow(
    categoryCode: catAppleWatch,
    modelShorthand: model,
    variants: [
      if (glass != null)
        VariantImportRow(
            code: 'glass_replacement', name: 'Ép kính', price: glass),
      if (touch != null)
        VariantImportRow(
            code: 'touch_replacement', name: 'Ép cảm ứng', price: touch),
    ],
  );
}

final List<ServiceImportRow> _appleWatchRepair = [
  _watchRow('WATCH2', glass: 400000, touch: 400000),
  _watchRow('WATCH3', glass: 400000, touch: 400000),
  _watchRow('WATCH4', glass: 400000, touch: 600000),
  _watchRow('WATCH5', glass: 400000, touch: 600000),
  _watchRow('WATCH6', glass: 400000, touch: 700000),
  _watchRow('WATCH7', glass: 600000, touch: 800000),
  _watchRow('WATCH8', glass: 800000, touch: 1000000),
  _watchRow('WATCH9', glass: 800000, touch: 1000000),
  _watchRow('WATCH10', glass: 1000000, touch: 1200000),
  _watchRow('WATCHSE', glass: 400000, touch: 600000),
  _watchRow('WATCHULTRA1', glass: 1000000), // touch = "-"
  _watchRow('WATCHULTRA2', glass: 1000000),
];

// ── 14. Ép kính iPad ────────────────────────────────────────────────────
final List<ServiceImportRow> _glassReplacementIpad = [
  _single(catEpKinhIpad, 'MINI4', 'glass_replacement', 'Ép kính', 345000),
  _single(catEpKinhIpad, 'MINI5', 'glass_replacement', 'Ép kính', 400000),
  _single(catEpKinhIpad, 'MINI6', 'glass_replacement', 'Ép kính', 590000),
  _single(catEpKinhIpad, 'AIR1', 'glass_replacement', 'Ép kính', 390000),
  _single(catEpKinhIpad, 'AIR2', 'glass_replacement', 'Ép kính', 425000),
  _single(catEpKinhIpad, 'GEN5', 'glass_replacement', 'Ép kính', 390000),
  _single(catEpKinhIpad, 'GEN6', 'glass_replacement', 'Ép kính', 390000),
  _single(catEpKinhIpad, 'GEN7', 'glass_replacement', 'Ép kính', 390000),
  _single(catEpKinhIpad, 'PRO97', 'glass_replacement', 'Ép kính', 415000),
  _single(catEpKinhIpad, 'PRO105', 'glass_replacement', 'Ép kính', 465000),
  _single(catEpKinhIpad, 'PRO11_2018', 'glass_replacement', 'Ép kính', 620000),
  _single(catEpKinhIpad, 'PRO11_2020', 'glass_replacement', 'Ép kính', 680000),
  _single(
      catEpKinhIpad, 'PRO11_2021_M1', 'glass_replacement', 'Ép kính', 720000),
  _single(catEpKinhIpad, 'PRO129_2015', 'glass_replacement', 'Ép kính', 500000),
  _single(catEpKinhIpad, 'PRO129_2017', 'glass_replacement', 'Ép kính', 550000),
  _single(catEpKinhIpad, 'PRO129_2018', 'glass_replacement', 'Ép kính', 650000),
  _single(catEpKinhIpad, 'PRO129_2020', 'glass_replacement', 'Ép kính', 700000),
  // Air 3/4/5, Gen 8/9/10, Pro 12.9 (2021, M1) intentionally NOT imported —
  // source price list has no entry for them (Phase 3 spec section 25).
];

/// Every production `repair_services` row to import, across all 14
/// categories. One entry per (categoryCode, modelShorthand) pair.
final List<ServiceImportRow> productionServiceImportRows = [
  ..._glassReplacementIphone,
  ..._faceId,
  ..._touchRepairIphone,
  ..._screenReplacementIphone,
  ..._airpodsBattery,
  ..._iphoneBattery,
  ..._samsungFoldFlip,
  ..._batteryCellReplacement,
  ..._rearCameraRepair,
  ..._backGlass,
  ..._touchRepairIpad,
  ..._ipadBattery,
  ..._appleWatchRepair,
  ..._glassReplacementIpad,
];
