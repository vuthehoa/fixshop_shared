import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:flutter_test/flutter_test.dart';

/// `catalog_model_offers/{modelId}` (MULTI_SERVICE_BOOKING_CONTRACT v2): every
/// `repair_services` write path recomputes the model summary from ALL services
/// of the model in the SAME transaction (rules enforce the same-transaction
/// part on the emulator — fixshop_cms test/multi_service_booking.rules.test.mjs).

RepairServiceVariantEntity _v(String code, int price, {bool enabled = true}) =>
    RepairServiceVariantEntity(
        code: code, name: code, price: price, enabled: enabled);

RepairServiceModel _draft(
  String categoryId, {
  String modelId = 'model-1',
  bool enabled = true,
  List<RepairServiceVariantEntity>? variants,
}) {
  final now = DateTime(2026, 1, 1);
  return RepairServiceModel(
    id: '',
    categoryId: categoryId,
    modelId: modelId,
    name: 'Dịch vụ $categoryId',
    enabled: enabled,
    variants: variants ?? [_v('${categoryId}_a', 100000)],
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

  Future<Map<String, dynamic>?> modelDoc(String modelId) async =>
      (await firestore
              .collection(FirestoreConstants.catalogModelOffers)
              .doc(modelId)
              .get())
          .data();

  test('pure: computeModelOffers keeps only bookable services, overrides win',
      () {
    final services = {
      's1': {
        'modelId': 'm',
        'status': 'active',
        'enabled': true,
        'variants': [
          {'code': 'a', 'price': 100000},
          {'code': 'b', 'price': 0},
          {'code': 'c', 'price': 50000, 'enabled': false},
        ],
      },
      's2': {
        'modelId': 'm',
        'status': 'archived',
        'variants': [
          {'code': 'a', 'price': 1},
        ],
      },
      's3': {
        'modelId': 'other',
        'status': 'active',
        'variants': [
          {'code': 'a', 'price': 1},
        ],
      },
      's4': {
        'modelId': 'm',
        'status': 'active',
        'variants': [
          {'code': 'x', 'price': 7},
        ],
      },
    };
    expect(computeModelOffers(modelId: 'm', services: services), {
      's1': {'a': 100000},
      's4': {'x': 7},
    });
    expect(
      computeModelOffers(modelId: 'm', services: services, overrides: {
        's4': const {},
        'new': {'z': 9},
      }),
      {
        's1': {'a': 100000},
        'new': {'z': 9},
      },
    );
  });

  test('create writes the model summary with ALL services of the model',
      () async {
    final a = await dataSource.createRepairService(_draft('screen'));
    final b = await dataSource.createRepairService(_draft('battery',
        variants: [_v('pin', 300000), _v('pin_pro', 500000)]));
    await dataSource.createRepairService(_draft('cam', modelId: 'model-2'));

    final m = await modelDoc('model-1');
    expect(m!.keys.toSet(), {'modelId', 'offers', 'syncedAt', 'source'});
    expect(m['modelId'], 'model-1');
    expect(m['source'], 'cms');
    expect(m['offers'], {
      a.id: {'screen_a': 100000},
      b.id: {'pin': 300000, 'pin_pro': 500000},
    });
    expect((await modelDoc('model-2'))!['offers'], hasLength(1));
  });

  test('update / archive / restore recompute the model summary', () async {
    final a = await dataSource.createRepairService(_draft('screen'));
    final b = await dataSource.createRepairService(_draft('battery'));

    await dataSource.updateRepairService(RepairServiceModel.fromEntity(b
        .copyWith(variants: [
      _v('battery_a', 120000),
      _v('off', 1, enabled: false)
    ])));
    expect((await modelDoc('model-1'))!['offers'], {
      a.id: {'screen_a': 100000},
      b.id: {'battery_a': 120000},
    });

    // Disabled service ⇒ dropped (not bookable), like catalog_eligibility.
    final stored = await dataSource.getRepairService(b.id);
    await dataSource.updateRepairService(
        RepairServiceModel.fromEntity(stored.copyWith(enabled: false)));
    expect(((await modelDoc('model-1'))!['offers'] as Map).keys, [a.id]);

    await dataSource.archiveRepairService(a.id);
    expect((await modelDoc('model-1'))!['offers'], isEmpty);

    await dataSource.restoreRepairService(a.id);
    expect((await modelDoc('model-1'))!['offers'], {
      a.id: {'screen_a': 100000},
    });
  });

  test('moving a service to another model rewrites BOTH model summaries',
      () async {
    final a = await dataSource.createRepairService(_draft('screen'));
    final b = await dataSource.createRepairService(_draft('battery'));
    final reported = <ModelOffersSyncResult>[];

    await dataSource.updateRepairService(
      RepairServiceModel.fromEntity(b.copyWith(modelId: 'model-2')),
      context: RepairServiceWriteContext(onModelOffersSynced: reported.add),
    );
    expect(((await modelDoc('model-1'))!['offers'] as Map).keys, [a.id]);
    expect(((await modelDoc('model-2'))!['offers'] as Map).keys, [b.id]);
    expect(reported.map((r) => r.modelId).toSet(), {'model-1', 'model-2'});
  });

  test('summary is recomputed from stored data (self-heals a stale doc)',
      () async {
    final a = await dataSource.createRepairService(_draft('screen'));
    await firestore
        .collection(FirestoreConstants.catalogModelOffers)
        .doc('model-1')
        .set({
      'modelId': 'model-1',
      'offers': {
        'ghost': {'x': 1}
      },
      'source': 'x',
    });
    await dataSource.createRepairService(_draft('battery'));
    final offers = (await modelDoc('model-1'))!['offers'] as Map;
    expect(offers.containsKey('ghost'), isFalse);
    expect(offers.containsKey(a.id), isTrue);
    expect(offers, hasLength(2));
  });

  test(
      'warns above the technical bound ($kServiceItemsTechnicalMax) — never blocks the save',
      () async {
    final reported = <ModelOffersSyncResult>[];
    final ctx = RepairServiceWriteContext(onModelOffersSynced: reported.add);
    for (var i = 0; i < kServiceItemsTechnicalMax; i++) {
      await dataSource.createRepairService(_draft('cat$i'), context: ctx);
    }
    expect(reported.last.bookableServices, kServiceItemsTechnicalMax);
    expect(reported.last.exceedsTechnicalMax, isFalse);
    expect(reported.last.warning, isNull);

    await dataSource.createRepairService(_draft('cat-over'), context: ctx);
    expect(reported.last.bookableServices, kServiceItemsTechnicalMax + 1);
    expect(reported.last.exceedsTechnicalMax, isTrue);
    expect(reported.last.warning, contains('$kServiceItemsTechnicalMax'));
    expect((await modelDoc('model-1'))!['offers'],
        hasLength(kServiceItemsTechnicalMax + 1));
  });

  test('eligibility is still written per service (single-service path)',
      () async {
    final a = await dataSource.createRepairService(_draft('screen'));
    final e = await firestore
        .collection(FirestoreConstants.catalogEligibility)
        .doc(a.id)
        .get();
    expect(e.data()!['offers'], {'screen_a': 100000});
  });
}
