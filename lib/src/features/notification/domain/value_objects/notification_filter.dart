import 'package:equatable/equatable.dart';

import '../entities/notification_entity.dart';

class NotificationFilter extends Equatable {
  final NotificationType? type;
  final String? customerId;
  final bool? unreadOnly;
  final int pageSize;

  const NotificationFilter({
    this.type,
    this.customerId,
    this.unreadOnly,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [type, customerId, unreadOnly, pageSize];
}
