import 'qr_payload_builder.dart';

/// Thin, injectable facade over [QrPayloadBuilder]. Exists as a class (not
/// static-only) so it can be resolved through DI and reused by future
/// modules (e.g. Repair Order tickets) without every call site depending on
/// the payload-format constant directly.
///
/// Rendering the payload into a scannable image is a presentation-layer
/// concern (see `QrPreview` in fixshop_cms, built on `qr_flutter`) — this
/// service only ever returns the payload string. Scanning/camera
/// integration is explicitly out of scope.
class QrCodeService {
  const QrCodeService();

  String buildDevicePayload(String deviceCode) =>
      QrPayloadBuilder.forDevice(deviceCode);
}
