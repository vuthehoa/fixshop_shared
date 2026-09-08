import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// Device-specific photo-gallery operations, built on top of
/// [ImageUploadService]. Not implemented in Sprint 5 — this interface only
/// reserves the architecture; the detail page's Photo Gallery section
/// renders whatever `photoUrls` already exist on the device without calling
/// this service.
abstract class DeviceImageService {
  Future<Either<Failure, List<String>>> addPhotos({
    required String deviceId,
    required List<List<int>> photoBytes,
  });

  Future<Either<Failure, void>> removePhoto({
    required String deviceId,
    required String photoUrl,
  });
}
