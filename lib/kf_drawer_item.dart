import 'package:flutter/material.dart';
import 'kf_drawer.dart';

class KFDrawerItem extends StatelessWidget {
  const KFDrawerItem({this.onPressed, this.text, this.icon, this.alias, this.page, Key? key}) : super(key: key);

  final GestureTapCallback? onPressed;
  final Widget? text;
  final Widget? icon;
  final String? alias;
  final Widget? page;

  factory KFDrawerItem.initWithPage({
    Widget? text,
    Widget? icon,
    String? alias,
    required Widget page,
  }) {
    return KFDrawerItem(
      text: text,
      icon: icon,
      alias: alias,
      page: page,
      onPressed: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ??
              (page != null
                  ? () {
                      final drawer = KFDrawer.of(context);
                      if (drawer != null) {
                        drawer.widget.controller?.page = page;
                        drawer.close();
                      }
                    }
                  : null),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 16.0, right: 8.0),
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
