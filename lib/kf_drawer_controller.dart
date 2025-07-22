import 'package:flutter/material.dart';
import 'kf_drawer_item.dart';

class KFDrawerController {
  KFDrawerController({this.items = const [], required Widget initialPage}) {
    this.page = initialPage;
  }

  List<KFDrawerItem> items;
  Function? close;
  Function? open;
  Function? toggle;
  Widget? page;
}
