import 'package:flutter/material.dart';

import 'kf_drawer.dart';

/// A tappable row displayed in a [KFDrawer].
class KFDrawerItem extends StatelessWidget {
  /// Creates a drawer item.
  const KFDrawerItem({
    super.key,
    this.onPressed,
    this.text,
    this.icon,
    this.alias,
    this.page,
    this.closeOnTap = true,
  });

  /// Creates a drawer item that selects [page] when tapped.
  factory KFDrawerItem.initWithPage({
    Widget? text,
    Widget? icon,
    String? alias,
    GestureTapCallback? onPressed,
    bool closeOnTap = true,
    required Widget page,
  }) {
    return KFDrawerItem(
      alias: alias,
      closeOnTap: closeOnTap,
      icon: icon,
      onPressed: onPressed,
      page: page,
      text: text,
    );
  }

  /// Creates a page-selecting drawer item with an optional extra callback.
  factory KFDrawerItem.withPage({
    Widget? text,
    Widget? icon,
    String? alias,
    GestureTapCallback? onPressed,
    bool closeOnTap = true,
    required Widget page,
  }) {
    return KFDrawerItem.initWithPage(
      alias: alias,
      closeOnTap: closeOnTap,
      icon: icon,
      onPressed: onPressed,
      page: page,
      text: text,
    );
  }

  /// Custom callback invoked when the item is tapped.
  final GestureTapCallback? onPressed;

  /// Primary item label.
  final Widget? text;

  /// Optional leading icon.
  final Widget? icon;

  /// Optional stable identifier used by controller lookup APIs.
  final String? alias;

  /// Optional page selected when the item is tapped.
  final Widget? page;

  /// Whether selecting [page] also closes the containing drawer.
  final bool closeOnTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: page == null && onPressed == null
              ? null
              : () {
                  final drawer = KFDrawer.of(context);
                  if (page != null) {
                    drawer?.setPage(page!);
                    if (closeOnTap) {
                      drawer?.close();
                    }
                  }
                  onPressed?.call();
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: <Widget>[
                if (icon != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 16,
                      end: 8,
                    ),
                    child: icon,
                  ),
                if (text != null) text!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
