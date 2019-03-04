library kf_drawer;

import 'package:flutter/material.dart';

class KFDrawerController {
  KFDrawerController({this.items, @required KFDrawerContent initialPage}) {
    this.page = initialPage;
  }

  List<KFDrawerItem> items;
  Function close;
  Function open;
  KFDrawerContent page;
}

class KFDrawerContent extends StatefulWidget {
  Function onMenuPressed;

  @override
  State<StatefulWidget> createState() {
    return null;
  }
}

class KFDrawer extends StatefulWidget {
  KFDrawer({
    Key key,
    this.header,
    this.footer,
    this.items,
    this.controller,
    this.decoration,
    this.drawerWidth,
    this.minScale,
  }) : super(key: key);

  Widget header;
  Widget footer;
  BoxDecoration decoration;
  List<KFDrawerItem> items;
  KFDrawerController controller;
  double drawerWidth;
  double minScale;

  @override
  _KFDrawerState createState() => _KFDrawerState();
}

class _KFDrawerState extends State<KFDrawer> with TickerProviderStateMixin {
  bool _menuOpened = false;
  bool _isDraggingMenu = false;

  double _drawerWidth = 0.66;
  double _minScale = 0.86;

  Animation<double> animation, scaleAnimation;
  Animation<BorderRadius> radiusAnimation;
  AnimationController animationController;

  _open() {
    animationController.forward();
    setState(() {
      _menuOpened = true;
    });
  }

  _close() {
    animationController.reverse();
    setState(() {
      _menuOpened = false;
    });
  }

  _onMenuPressed() {
    _menuOpened ? _close() : _open();
  }

  _finishDrawerAnimation() {
    if (_isDraggingMenu) {
      var opened = false;
      setState(() {
        _isDraggingMenu = false;
      });
      if (animationController.value >= 0.4) {
        animationController.forward();
        opened = true;
      } else {
        animationController.reverse();
      }
      setState(() {
        _menuOpened = opened;
      });
    }
  }

  List<KFDrawerItem> _getDrawerItems() {
    if (widget.controller.items != null) {
      return widget.controller.items.map((KFDrawerItem item) {
        if (item.onPressed == null) {
          item.onPressed = () {
            widget.controller.page = item.page;
            widget.controller.close();
          };
        }
        item.page.onMenuPressed = _onMenuPressed;
        return item;
      }).toList();
    }
    return widget.items;
  }

  @override
  void initState() {
    super.initState();
    if (widget.minScale != null) {
      _minScale = widget.minScale;
    }
    if (widget.drawerWidth != null) {
      _drawerWidth = widget.drawerWidth;
    }
    animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController)
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
      });

    scaleAnimation = Tween<double>(begin: 1.0, end: _minScale).animate(animationController);
    radiusAnimation = BorderRadiusTween(begin: BorderRadius.circular(0.0), end: BorderRadius.circular(32.0))
        .animate(CurvedAnimation(parent: animationController, curve: Curves.ease));
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.page.onMenuPressed = _onMenuPressed;
    widget.controller.close = _close;
    widget.controller.open = _open;

    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) async {
        setState(() {
          _isDraggingMenu =
              (_menuOpened && details.globalPosition.dx / MediaQuery.of(context).size.width >= _drawerWidth) ||
                  (!_menuOpened && details.globalPosition.dx <= 8.0);
        });
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) async {
        if (_isDraggingMenu) {
          animationController.value = details.globalPosition.dx / MediaQuery.of(context).size.width;
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) async {
        _finishDrawerAnimation();
      },
      onHorizontalDragCancel: () async {
        _finishDrawerAnimation();
      },
      child: Stack(
        children: <Widget>[
          _KFDrawer(
            animationController: animationController,
            header: widget.header,
            footer: widget.footer,
            items: _getDrawerItems(),
            decoration: widget.decoration,
          ),
          Transform.scale(
            scale: scaleAnimation.value,
            child: Transform.translate(
              offset: Offset((MediaQuery.of(context).size.width * _drawerWidth) * animation.value, 0.0),
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(44.0)),
                            child: Container(
                              color: Colors.white.withAlpha(128),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: animation.value * 16.0),
                    child: ClipRRect(
                      borderRadius: radiusAnimation.value,
                      child: Container(
                        color: Colors.white,
                        child: widget.controller.page,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class _KFDrawer extends StatefulWidget {
  _KFDrawer({Key key, this.animationController, this.header, this.footer, this.items, this.decoration});

  Widget header;
  Widget footer;
  List<KFDrawerItem> items;
  BoxDecoration decoration;

  Animation<double> animationController;

  @override
  __KFDrawerState createState() => __KFDrawerState();
}

class __KFDrawerState extends State<_KFDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.decoration,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 64.0),
        child: Column(
          children: <Widget>[
            Container(
              child: widget.header,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.items,
              ),
            ),
            widget.footer,
          ],
        ),
      ),
    );
  }
}

class KFDrawerItem extends StatelessWidget {
  KFDrawerItem({this.onPressed, this.text, this.icon});

  KFDrawerItem.initWithPage({this.onPressed, this.text, this.icon, this.alias, this.page});

  Function onPressed;
  Widget text;
  Widget icon;

  String alias;
  KFDrawerContent page;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 16.0, right: 8.0),
                  child: icon,
                ),
                text,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
