enum SortOrder { asc, desc }

class Meta {
  num? page = 1;
  num? perPage = 15;
  String? search = '';
  bool? showAll = false;
  String? sortBy = '';
  SortOrder? sortOrder = SortOrder.asc;

  Meta({
    this.page,
    this.perPage,
    this.search,
    this.showAll,
    this.sortBy,
    this.sortOrder,
  });
}
