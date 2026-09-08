import 'package:equatable/equatable.dart';

/// Who physically picked up the device — not always the customer on file.
enum HandoverRecipientRelationship {
  customer,
  familyMember,
  representative,
  other;

  String get displayName => switch (this) {
        HandoverRecipientRelationship.customer => 'Khách hàng',
        HandoverRecipientRelationship.familyMember => 'Người thân',
        HandoverRecipientRelationship.representative => 'Người được uỷ quyền',
        HandoverRecipientRelationship.other => 'Khác',
      };

  static HandoverRecipientRelationship fromName(String? value) =>
      switch (value) {
        'customer' => HandoverRecipientRelationship.customer,
        'familyMember' => HandoverRecipientRelationship.familyMember,
        'representative' => HandoverRecipientRelationship.representative,
        'other' => HandoverRecipientRelationship.other,
        _ => HandoverRecipientRelationship.customer,
      };
}

/// The customer-handover record captured at delivery — embedded on
/// [RepairOrderEntity], not a separate collection.
///
/// Deliberately does NOT duplicate who/when performed the handover:
/// [RepairOrderEntity.deliveredAt]/[RepairOrderEntity.deliveredBy] already
/// answer "when" and "which staff member" (same convention as
/// `receivedAt`/`receivedBy`), so this only holds facts about the recipient.
class DeliveryInfo extends Equatable {
  final String recipientName;
  final HandoverRecipientRelationship recipientRelationship;
  final String? handoverNotes;

  const DeliveryInfo({
    required this.recipientName,
    this.recipientRelationship = HandoverRecipientRelationship.customer,
    this.handoverNotes,
  });

  factory DeliveryInfo.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const DeliveryInfo(recipientName: '');
    }
    return DeliveryInfo(
      recipientName: map['recipientName'] as String? ?? '',
      recipientRelationship: HandoverRecipientRelationship.fromName(
          map['recipientRelationship'] as String?),
      handoverNotes: map['handoverNotes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipientName': recipientName,
      'recipientRelationship': recipientRelationship.name,
      'handoverNotes': handoverNotes,
    };
  }

  @override
  List<Object?> get props =>
      [recipientName, recipientRelationship, handoverNotes];
}
