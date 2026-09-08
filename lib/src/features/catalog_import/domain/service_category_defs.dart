import 'package:equatable/equatable.dart';

/// One of the 14 production service categories, with its stable `code` and
/// deterministic display `order`. Pure data — see Phase 3 spec section 9-10.
class ServiceCategoryDef extends Equatable {
  final String code;
  final String name;
  final int order;

  const ServiceCategoryDef({
    required this.code,
    required this.name,
    required this.order,
  });

  @override
  List<Object?> get props => [code, name, order];
}

const catEpKinhIphone = 'iphone_glass_replacement';
const catFaceId = 'iphone_face_id';
const catEpCamUngIphone = 'iphone_touch_repair';
const catGiaManIphone = 'iphone_screen_replacement';
const catPinAirpods = 'airpods_battery';
const catPinIphone = 'iphone_battery';
const catSamsungFoldFlip = 'samsung_fold_flip';
const catThayPhoiPin = 'iphone_battery_cell_replacement';
const catCameraSau = 'iphone_rear_camera_repair';
const catThayLung = 'iphone_back_glass';
const catEpCamUngIpad = 'ipad_touch_repair';
const catPinIpad = 'ipad_battery';
const catAppleWatch = 'apple_watch_repair';
const catEpKinhIpad = 'ipad_glass_replacement';

/// The 14 production service categories, in their required display order.
final List<ServiceCategoryDef> productionServiceCategories = [
  const ServiceCategoryDef(
      code: catEpKinhIphone, name: 'Ép kính iPhone', order: 10),
  const ServiceCategoryDef(code: catFaceId, name: 'Face ID', order: 20),
  const ServiceCategoryDef(
      code: catEpCamUngIphone, name: 'Ép cảm ứng iPhone', order: 30),
  const ServiceCategoryDef(
      code: catGiaManIphone, name: 'Giá màn iPhone', order: 40),
  const ServiceCategoryDef(code: catPinAirpods, name: 'Pin AirPods', order: 50),
  const ServiceCategoryDef(code: catPinIphone, name: 'Pin iPhone', order: 60),
  const ServiceCategoryDef(
      code: catSamsungFoldFlip, name: 'Samsung Fold / Flip', order: 70),
  const ServiceCategoryDef(
      code: catThayPhoiPin, name: 'Thay phôi pin iPhone', order: 80),
  const ServiceCategoryDef(
      code: catCameraSau, name: 'Sửa camera sau iPhone', order: 90),
  const ServiceCategoryDef(
      code: catThayLung, name: 'Thay lưng iPhone', order: 100),
  const ServiceCategoryDef(
      code: catEpCamUngIpad, name: 'Ép cảm ứng iPad', order: 110),
  const ServiceCategoryDef(code: catPinIpad, name: 'Pin iPad', order: 120),
  const ServiceCategoryDef(
      code: catAppleWatch, name: 'Apple Watch', order: 130),
  const ServiceCategoryDef(
      code: catEpKinhIpad, name: 'Ép kính iPad', order: 140),
];
