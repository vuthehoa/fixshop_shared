import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// Generic file-storage upload extension point (e.g. Firebase Storage).
/// Not implemented in Sprint 5 — this interface only reserves the
/// architecture so a future sprint can add an implementation without
/// touching call sites that only need a URL back.
abstract class ImageUploadService {
  Future<Either<Failure, String>> upload({
    required String path,
    required List<int> fileBytes,
  });

  Future<Either<Failure, void>> delete(String path);
}
