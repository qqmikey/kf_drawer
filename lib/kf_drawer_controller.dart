import 'package:flutter/widgets.dart';

import 'kf_drawer_item.dart';

/// Controls the visible page and programmatic state of a [KFDrawer].
///
/// The [page] and [items] setters notify the attached drawer automatically.
/// Mutating the returned [items] list in place requires [refreshItems], though
/// [addItem], [removeItem], and [clearItems] are preferred.
class KFDrawerController extends ChangeNotifier {
  /// Creates a controller with the first page displayed by the drawer.
  KFDrawerController({
    List<KFDrawerItem> items = const <KFDrawerItem>[],
    required Widget initialPage,
    this.maintainPageHistory = false,
  })  : _items = List<KFDrawerItem>.of(items),
        _page = initialPage;

  List<KFDrawerItem> _items = const <KFDrawerItem>[];
  Widget? _page;
  final List<Widget> _pageHistory = <Widget>[];

  /// Callback installed by the attached drawer to close it.
  Function? close;

  /// Callback installed by the attached drawer to open it.
  Function? open;

  /// Callback installed by the attached drawer to toggle it.
  Function? toggle;

  /// Whether assigning [page] records the previous page for [goBack].
  final bool maintainPageHistory;

  /// The menu items displayed by the attached drawer.
  List<KFDrawerItem> get items => _items;

  set items(List<KFDrawerItem> value) {
    _items = List<KFDrawerItem>.of(value);
    notifyListeners();
  }

  /// The page displayed as drawer content.
  Widget? get page => _page;

  set page(Widget? value) {
    if (identical(_page, value)) {
      return;
    }
    if (maintainPageHistory && _page != null && value != null) {
      _pageHistory.add(_page!);
    }
    _page = value;
    notifyListeners();
  }

  /// Whether [goBack] can restore a previously displayed page.
  bool get canGoBack => _pageHistory.isNotEmpty;

  /// Adds [item] and refreshes the attached drawer.
  void addItem(KFDrawerItem item) {
    _items.add(item);
    notifyListeners();
  }

  /// Removes [item] and refreshes the attached drawer.
  bool removeItem(KFDrawerItem item) {
    final removed = _items.remove(item);
    if (removed) {
      notifyListeners();
    }
    return removed;
  }

  /// Removes all menu items and refreshes the attached drawer.
  void clearItems() {
    if (_items.isEmpty) {
      return;
    }
    _items.clear();
    notifyListeners();
  }

  /// Notifies the drawer after [items] was mutated directly.
  void refreshItems() {
    notifyListeners();
  }

  /// Selects the first item whose alias equals [alias].
  ///
  /// Returns `false` if the alias is unknown or the item has no page.
  bool selectItem(String alias) {
    for (final item in _items) {
      if (item.alias == alias && item.page != null) {
        page = item.page;
        return true;
      }
    }
    return false;
  }

  /// Displays [value] without adding the current page to history.
  void replacePage(Widget? value) {
    if (identical(_page, value)) {
      return;
    }
    _page = value;
    notifyListeners();
  }

  /// Restores the previous page when page history is enabled.
  ///
  /// Returns `true` when a page was restored.
  bool goBack() {
    if (_pageHistory.isEmpty) {
      return false;
    }
    _page = _pageHistory.removeLast();
    notifyListeners();
    return true;
  }

  /// Clears all pages recorded for [goBack].
  void clearHistory() {
    if (_pageHistory.isEmpty) {
      return;
    }
    _pageHistory.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    close = null;
    open = null;
    toggle = null;
    super.dispose();
  }
}
