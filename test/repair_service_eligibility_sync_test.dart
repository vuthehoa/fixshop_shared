import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every `repair_services` write path in the shared datasource must write
/// `catalog_eligibility/{id}` alongside it (contract §2). Rules enforce the
/// same-batch + `syncedAt == request.time` part on the emulator (see
/// fixshop_cms test/firestore.rules.test.mjs); this suite proves the payload
/// and that no write path forgets it.

const _pisen = RepairServiceVariantEntity(
  code: 'battery_pisen_bh6',
  name: 'Pin Pisen',
  price: 810000,
);

RepairServiceModel _draft({
  bool enabled = true,
  List<RepairServiceVariantEntity> variants = const [_pisen],
}) {
  final now = DateTime(2026, 1, 1);
  return RepairServiceModel(
    id: '',
    categoryId: 'cat-1',
    modelId: 'model-1',
    name: 'Thay pin iPhone 13',
    enabled: enabled,
    variants: variants,
    createdAt: now,
    updatedAt: now,
    createdBy: 'user-1',
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late FirebaseRepairServiceRemoteDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = FirebaseRepairServiceRemoteDataSource(firestore: firestore);
  });

  Future<Map<String, dynamic>> eligibility(String id) async {
    final doc = await firestore
        .collection(FirestoreConstants.catalogEligibility)
        .doc(id)
        .get();
    expect(doc.exists, isTrue, reason: 'catalog_eligibility/$id missing');
    return doc.data()!;
  }

  Future<List<Map<String, dynamic>>> logs() async {
    final snap =
        await firestore.collection(FirestoreConstants.activityLogs).get();
    return snap.docs.map((d) => d.data()).toList();
  }

  test('create writes eligibility with offers, modelId, source and syncedAt',
      () async {
    final created = await dataSource.createRepairService(_draft());

    final e = await eligibility(created.id);
    expect(e.keys.toSet(), {'modelId', 'offers', 'syncedAt', 'source'});
    expect(e['modelId'], 'model-1');
    expect(e['offers'], {'battery_pisen_bh6': 810000});
    expect(e['source'], 'cms');
    expect(e['syncedAt'], isA<Timestamp>()); // serverTimestamp resolved
  });

  test('create with source=import stamps "import"', () async {
    final created = await dataSource.createRepairService(
      _draft(),
      context: const RepairServiceWriteContext(
          source: CatalogEligibilitySource.importer),
    );
    expect((await eligibility(created.id))['source'], 'import');
  });

  test('create of a disabled service writes offers = {}', () async {
    final created =
        await dataSource.createRepairService(_draft(enabled: false));
    expect((await eligibility(created.id))['offers'], isEmpty);
  });

  test('create rejects an enabled variant priced 0 (nothing written)',
      () async {
    await expectLater(
      dataSource
          .createRepairService(_draft(variants: [_pisen.copyWith(price: 0)])),
      throwsA(isA<CatalogValidationException>()),
    );
    final services =
        await firestore.collection(FirestoreConstants.repairServices).get();
    final elig =
        await firestore.collection(FirestoreConstants.catalogEligibility).get();
    expect(services.docs, isEmpty);
    expect(elig.docs, isEmpty);
  });

  test('update re-syncs offers and writes a pricing audit log', () async {
    final created = await dataSource.createRepairService(_draft());

    await dataSource.updateRepairService(
      RepairServiceModel.fromEntity(created.copyWith(variants: [
        _pisen.copyWith(price: 900000),
        const RepairServiceVariantEntity(
            code: 'battery_cell', name: 'Cell zin', price: 0, enabled: false),
      ])),
      context: const RepairServiceWriteContext(
        actorId: 'user-1',
        actorRole: UserRole.manager,
      ),
    );

    expect((await eligibility(created.id))['offers'],
        {'battery_pisen_bh6': 900000});

    final entries = await logs();
    expect(entries, hasLength(1));
    final log = entries.single;
    expect(log['action'], ActivityActions.updateRepairServicePricing);
    expect(log['actorId'], 'user-1');
    expect(log['actorRole'], 'manager');
    expect(log['targetId'], created.id);
    expect(log['timestamp'], isA<Timestamp>());
    final meta = log['metadata'] as Map<String, dynamic>;
    expect(meta['serviceId'], created.id);
    expect(meta['modelId'], 'model-1');
    expect(meta['categoryId'], 'cat-1');
    final changes = (meta['changes'] as List).cast<Map>();
    expect(changes, hasLength(2));
    expect(changes.first, {
      'variantCode': 'battery_pisen_bh6',
      'variantName': 'Pin Pisen',
      'warrantyMonths': 6,
      'oldPrice': 810000,
      'newPrice': 900000,
      'oldEnabled': true,
      'newEnabled': true,
    });
    expect(changes.last['variantCode'], 'battery_cell');
    expect(changes.last['oldPrice'], isNull);
  });

  test('update without a price/enabled change writes no audit log', () async {
    final created = await dataSource.createRepairService(_draft());
    await dataSource.updateRepairService(
      RepairServiceModel.fromEntity(created.copyWith(name: 'Tên mới')),
      context: const RepairServiceWriteContext(
          actorId: 'user-1', actorRole: UserRole.admin),
    );
    expect(await logs(), isEmpty);
    expect((await eligibility(created.id))['offers'],
        {'battery_pisen_bh6': 810000});
  });

  test('update without an actor still syncs eligibility, but cannot audit',
      () async {
    final created = await dataSource.createRepairService(_draft());
    await dataSource.updateRepairService(
      RepairServiceModel.fromEntity(created.copyWith(enabled: false)),
    );
    expect((await eligibility(created.id))['offers'], isEmpty);
    expect(await logs(), isEmpty);
  });

  test('update keeps the stored status: an archived service stays offers = {}',
      () async {
    final created = await dataSource.createRepairService(_draft());
    await dataSource.archiveRepairService(created.id);

    // The form passes an entity whose status may be stale ("active").
    await dataSource.updateRepairService(
      RepairServiceModel.fromEntity(
          created.copyWith(variants: [_pisen.copyWith(price: 1000000)])),
    );
    expect((await eligibility(created.id))['offers'], isEmpty);
  });

  test('archive ⇒ offers = {}; restore ⇒ offers recomputed', () async {
    final created = await dataSource.createRepairService(_draft());

    await dataSource.archiveRepairService(created.id);
    var e = await eligibility(created.id);
    expect(e['offers'], isEmpty);
    expect(e['modelId'], 'model-1');
    final svc = await firestore
        .collection(FirestoreConstants.repairServices)
        .doc(created.id)
        .get();
    expect(svc.data()!['status'], 'archived');

    await dataSource.restoreRepairService(created.id);
    e = await eligibility(created.id);
    expect(e['offers'], {'battery_pisen_bh6': 810000});
  });

  test('restore of a legacy doc judges raw prices by the contract', () async {
    final ref = firestore.collection(FirestoreConstants.repairServices).doc();
    await ref.set({
      'modelId': 'model-legacy',
      'name': 'Legacy',
      'status': 'archived',
      // `enabled` missing ⇒ legacy default true.
      'variants': [
        {'code': 'frac', 'price': 1.5, 'enabled': true},
        {'code': 'ok', 'price': 450000, 'enabled': true},
      ],
    });

    await dataSource.restoreRepairService(ref.id);
    final e = await eligibility(ref.id);
    expect(e['modelId'], 'model-legacy');
    expect(e['offers'], {'ok': 450000});
  });

  test('archive/restore of a missing document throws NotFound', () async {
    await expectLater(dataSource.archiveRepairService('nope'),
        throwsA(isA<NotFoundException>()));
    final elig =
        await firestore.collection(FirestoreConstants.catalogEligibility).get();
    expect(elig.docs, isEmpty);
  });
}
