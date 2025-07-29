List<T> paginate<T>({
  required List<T> items,
  required int page,
  required int itemsPerPage,
}) {
  final start = (page - 1) * itemsPerPage;
  if (start >= items.length) return [];

  final end = start + itemsPerPage;
  return items.sublist(start, end > items.length ? items.length : end);
}

int totalPages({required int itemCount, required int itemsPerPage}) {
  return (itemCount / itemsPerPage).ceil();
}
