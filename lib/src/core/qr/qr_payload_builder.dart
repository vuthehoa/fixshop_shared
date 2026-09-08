/// Builds the QR payload strings used across the app. Pure functions only —
/// no rendering, no persistence, no scanning. Single source of truth so the
/// `DEVICE-{deviceCode}` format is never duplicated at call sites.
abstract final class QrPayloadBuilder {
  static const String _devicePrefix = 'DEVICE-';

  static String forDevice(String deviceCode) => '$_devicePrefix$deviceCode';

  /// Reverses [forDevice] — the single place a scanned/typed payload is
  /// parsed back into a `deviceCode`. Returns `null` for anything that
  /// doesn't match the current format (wrong prefix, empty code), so callers
  /// never have to duplicate the parsing rule to validate input.
  static String? parseDeviceCode(String payload) {
    final trimmed = payload.trim();
    if (!trimmed.startsWith(_devicePrefix)) return null;
    final code = trimmed.substring(_devicePrefix.length).trim();
    return code.isEmpty ? null : code;
  }
}
