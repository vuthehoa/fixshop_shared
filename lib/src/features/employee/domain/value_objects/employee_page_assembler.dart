import 'package:equatable/equatable.dart';

/// Outcome of trimming an over-fetched employee result down to a single page.
class EmployeePageResult<T> extends Equatable {
  final List<T> items;
  final bool hasMore;

  const EmployeePageResult({required this.items, required this.hasMore});

  @override
  List<Object?> get props => [items, hasMore];
}

/// Trims [accepted] — every row that survived client-side filtering across one
/// or more Firestore fetch rounds — down to at most [pageSize] rows.
///
///  * More than [pageSize] rows collected  -> there is another page.
///  * Otherwise, and Firestore was drained -> this is the last page.
///  * Otherwise (we stopped early, e.g. a round cap) -> assume another page so
///    the caller can still ask; a follow-up request simply returns fewer rows.
EmployeePageResult<T> assembleEmployeePage<T>({
  required List<T> accepted,
  required int pageSize,
  required bool firestoreExhausted,
}) {
  final overflow = accepted.length > pageSize;
  final items = overflow ? accepted.sublist(0, pageSize) : List<T>.of(accepted);
  return EmployeePageResult<T>(
    items: items,
    hasMore: overflow || !firestoreExhausted,
  );
}
