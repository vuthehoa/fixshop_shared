import 'package:equatable/equatable.dart';

/// Physical-condition checklist captured when a device is received from the
/// customer. `receivedAt`/`receivedBy` live on [RepairOrderEntity] itself
/// (they answer "when"/"who"); this only holds the condition details.
///
/// Signatures and before-repair photos are placeholders only — no capture
/// UI, no upload, no PDF. They exist so the schema doesn't need to change
/// again once a later sprint implements them.
class ReceptionInfo extends Equatable {
  final String? externalCondition;
  final String? accessoriesReceived;
  final int? batteryPercent;
  final String? screenCondition;
  final String? bodyCondition;
  final String? cameraCondition;
  final bool? hasWaterDamage;
  final String? lockStatus;
  final String? simStatus;
  final String? customerSignatureUrl;
  final String? staffSignatureUrl;
  final List<String> photosBeforeRepair;

  const ReceptionInfo({
    this.externalCondition,
    this.accessoriesReceived,
    this.batteryPercent,
    this.screenCondition,
    this.bodyCondition,
    this.cameraCondition,
    this.hasWaterDamage,
    this.lockStatus,
    this.simStatus,
    this.customerSignatureUrl,
    this.staffSignatureUrl,
    this.photosBeforeRepair = const [],
  });

  factory ReceptionInfo.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ReceptionInfo();
    return ReceptionInfo(
      externalCondition: map['externalCondition'] as String?,
      accessoriesReceived: map['accessoriesReceived'] as String?,
      batteryPercent: map['batteryPercent'] as int?,
      screenCondition: map['screenCondition'] as String?,
      bodyCondition: map['bodyCondition'] as String?,
      cameraCondition: map['cameraCondition'] as String?,
      hasWaterDamage: map['hasWaterDamage'] as bool?,
      lockStatus: map['lockStatus'] as String?,
      simStatus: map['simStatus'] as String?,
      customerSignatureUrl: map['customerSignatureUrl'] as String?,
      staffSignatureUrl: map['staffSignatureUrl'] as String?,
      photosBeforeRepair:
          (map['photosBeforeRepair'] as List<dynamic>?)?.cast<String>() ??
              const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'externalCondition': externalCondition,
      'accessoriesReceived': accessoriesReceived,
      'batteryPercent': batteryPercent,
      'screenCondition': screenCondition,
      'bodyCondition': bodyCondition,
      'cameraCondition': cameraCondition,
      'hasWaterDamage': hasWaterDamage,
      'lockStatus': lockStatus,
      'simStatus': simStatus,
      'customerSignatureUrl': customerSignatureUrl,
      'staffSignatureUrl': staffSignatureUrl,
      'photosBeforeRepair': photosBeforeRepair,
    };
  }

  @override
  List<Object?> get props => [
        externalCondition,
        accessoriesReceived,
        batteryPercent,
        screenCondition,
        bodyCondition,
        cameraCondition,
        hasWaterDamage,
        lockStatus,
        simStatus,
        customerSignatureUrl,
        staffSignatureUrl,
        photosBeforeRepair,
      ];
}
