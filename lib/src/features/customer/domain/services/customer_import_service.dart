import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// Result of an import run: how many rows succeeded vs. were rejected, with
/// a per-row reason for every rejection so the caller can show a report.
class CustomerImportResult {
  final int importedCount;
  final List<CustomerImportRowError> errors;

  const CustomerImportResult({
    required this.importedCount,
    required this.errors,
  });
}

class CustomerImportRowError {
  final int rowNumber;
  final String reason;

  const CustomerImportRowError({required this.rowNumber, required this.reason});
}

/// Extension point for bulk-importing customers from an external file
/// (e.g. Excel/CSV). Not implemented in Sprint 4 — this interface only
/// reserves the architecture so Sprint 5+ can add an implementation without
/// touching the customer list/detail/cubit call sites.
abstract class CustomerImportService {
  Future<Either<Failure, CustomerImportResult>> importFromFile(
      List<int> fileBytes);
}
