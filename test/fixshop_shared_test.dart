import 'package:flutter_test/flutter_test.dart';

import 'package:fixshop_shared/fixshop_shared.dart';

void main() {
  test('UserRole.isCmsUser returns false for customer', () {
    expect(UserRole.customer.isCmsUser, isFalse);
    expect(UserRole.admin.isCmsUser, isTrue);
    expect(UserRole.manager.isCmsUser, isTrue);
    expect(UserRole.reception.isCmsUser, isTrue);
    expect(UserRole.technician.isCmsUser, isTrue);
  });
}
