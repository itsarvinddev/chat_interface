import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Extensions to safely mutate PagingController state while preserving keys,
/// error, loading flags, and page count.
/// - Adds items to the first page (either append or prepend).
/// - If no pages exist, creates the first page and initializes keys with the
///   controller's `firstPageKey`.
extension PagingControllerFirstPageExtensions<K, T> on PagingController<K, T> {
  /// Add a single [item] to the first page.
  /// - If [prepend] is true, inserts at the start of the first page.
  /// - Otherwise, appends to the end of the first page.
  /// - If there are no pages yet, creates the first page with this [item]
  ///   and initializes the keys with `this.firstPageKey`.
  void addItemToFirstPage(T item, {bool prepend = false}) {
    final state = value;
    final pages = state.pages;

    // Create the first page when there are no pages yet.
    if (pages == null || pages.isEmpty) {
      final newFirstPage = <T>[item];
      final newPages = <List<T>>[newFirstPage];

      value = state.copyWith(
        pages: newPages,
        // NOTE: `this.firstPageKey` is the controller's initial page key.
        // keys: <K>[this.firstPageKey],
      );
      return;
    }

    // Deep copy pages and update only the first page's items.
    final updatedFirstPage = List<T>.of(pages.first);
    if (prepend) {
      updatedFirstPage.insert(0, item);
    } else {
      updatedFirstPage.add(item);
    }

    final updatedPages = List<List<T>>.generate(
      pages.length,
      (i) => i == 0 ? updatedFirstPage : List<T>.of(pages[i]),
      growable: false,
    );

    value = state.copyWith(pages: updatedPages);
  }

  /// Add multiple [items] to the first page.
  /// - If [prepend] is true, inserts items at the start of the first page
  ///   preserving the provided order.
  /// - Otherwise, appends the items to the end of the first page.
  /// - If there are no pages yet, creates the first page with these [items]
  ///   and initializes the keys with `this.firstPageKey`.
  void addItemsToFirstPage(Iterable<T> items, {bool prepend = false}) {
    final batch = items is List<T> ? items : List<T>.of(items);
    if (batch.isEmpty) return;

    final state = value;
    final pages = state.pages;

    // Create the first page when there are no pages yet.
    if (pages == null || pages.isEmpty) {
      final newFirstPage = <T>[...batch];
      final newPages = <List<T>>[newFirstPage];

      value = state.copyWith(
        pages: newPages,
        // keys: <K>[this.firstPageKey],
      );
      return;
    }

    // Deep copy pages and update only the first page's items.
    final updatedFirstPage = List<T>.of(pages.first);
    if (prepend) {
      updatedFirstPage.insertAll(0, batch);
    } else {
      updatedFirstPage.addAll(batch);
    }

    final updatedPages = List<List<T>>.generate(
      pages.length,
      (i) => i == 0 ? updatedFirstPage : List<T>.of(pages[i]),
      growable: false,
    );

    value = state.copyWith(pages: updatedPages);
  }
}
