import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/paginated_result.dart';
import '../../domain/value_objects/model_filter.dart';
import '../models/model_model.dart';

abstract class ModelRemoteDataSource {
  Future<ModelModel> getModel(String id);

  Future<PaginatedResult<ModelModel>> getModels(
    ModelFilter filter, {
    DocumentSnapshot? startAfter,
  });

  Future<List<ModelModel>> getActiveModels({String? parentId});

  Future<ModelModel> createModel(ModelModel entity);

  Future<ModelModel> updateModel(ModelModel entity);

  Future<void> archiveModel(String id);

  Future<void> restoreModel(String id);
}
