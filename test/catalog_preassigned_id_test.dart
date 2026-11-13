import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:fixshop_shared/src/features/manufacturer/data/models/manufacturer_model.dart';
import 'package:fixshop_shared/src/features/model/data/models/model_model.dart';
import 'package:fixshop_shared/src/features/product_family/data/models/product_family_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// CMS reserves a document id before the first save so catalog images can be
/// uploaded to `catalog/<collection>/<id>/…` while the create form is open.
void main() {
  final now = DateTime(2026, 1, 1);

  test('manufacturer: pre-assigned id is used and coverUrl round-trips',
      () async {
    final firestore = FakeFirebaseFirestore();
    final ds = FirebaseManufacturerRemoteDataSource(firestore: firestore);

    final created = await ds.createManufacturer(ManufacturerModel(
      id: 'reserved-1',
      code: 'apple',
      name: 'Apple',
      logoUrl: 'https://firebasestorage.googleapis.com/logo.png',
      coverUrl: 'https://firebasestorage.googleapis.com/cover.webp',
      createdAt: now,
      updatedAt: now,
    ));

    expect(created.id, 'reserved-1');
    final stored = await ds.getManufacturer('reserved-1');
    expect(
        stored.coverUrl, 'https://firebasestorage.googleapis.com/cover.webp');

    final updated = await ds.updateManufacturer(
        ManufacturerModel.fromEntity(stored.copyWith(coverUrl: 'https://x/y')));
    expect(updated.coverUrl, 'https://x/y');
  });

  test('manufacturer: a pre-assigned id never overwrites an existing doc',
      () async {
    final firestore = FakeFirebaseFirestore();
    final ds = FirebaseManufacturerRemoteDataSource(firestore: firestore);
    await firestore
        .collection(FirestoreConstants.manufacturers)
        .doc('taken')
        .set({'code': 'samsung', 'name': 'Samsung', 'status': 'active'});

    await expectLater(
      ds.createManufacturer(ManufacturerModel(
        id: 'taken',
        code: 'apple',
        name: 'Apple',
        createdAt: now,
        updatedAt: now,
      )),
      throwsA(isA<DuplicateCodeException>()),
    );
  });

  test('model + product family: empty id still auto-generates', () async {
    final firestore = FakeFirebaseFirestore();
    final families =
        FirebaseProductFamilyRemoteDataSource(firestore: firestore);
    final models = FirebaseModelRemoteDataSource(firestore: firestore);

    final family = await families.createProductFamily(ProductFamilyModel(
      id: '',
      code: 'iphone',
      name: 'iPhone',
      manufacturerId: 'm1',
      createdAt: now,
      updatedAt: now,
    ));
    expect(family.id, isNotEmpty);

    final model = await models.createModel(ModelModel(
      id: 'reserved-model',
      code: 'iphone_15',
      name: 'iPhone 15',
      productFamilyId: family.id,
      createdAt: now,
      updatedAt: now,
    ));
    expect(model.id, 'reserved-model');
  });
}
