library kf_drawer;

import 'package:flutter/material.dart';

class KFDrawerController {
  KFDrawerController({this.items = const [], required KFDrawerContent initialPage}) {
    this.page = initialPage;
  }

  List<KFDrawerItem> items;
  Function? close;
  Function? open;
  KFDrawerContent? page;
}

// ignore: must_be_immutable
class KFDrawerContent extends StatefulWidget {
  VoidCallback? onMenuPressed;

  @override
  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }
}

class KFDrawer extends StatefulWidget {
  KFDrawer({
    Key? key,
    this.header,
    this.footer,
    this.items = const [],
    this.controller,
    this.decoration,
    this.drawerWidth,
    this.minScale,
    this.borderRadius,
    this.shadowBorderRadius,
    this.shadowOffset,
    this.scrollable = true,
    this.menuPadding,
    this.disableContentTap = true,
  }) : super(key: key);

  Widget? header;
  Widget? footer;
  BoxDecoration? decoration;
  List<KFDrawerItem> items;
  KFDrawerController? controller;
  double? drawerWidth;
  double? minScale;
  double? borderRadius;
  double? shadowBorderRadius;
  double? shadowOffset;
  bool scrollable;
  EdgeInsets? menuPadding;
  bool disableContentTap;

  @override
  _KFDrawerState createState() => _KFDrawerState();
}

class _KFDrawerState extends State<KFDrawer> with TickerProviderStateMixin {
  bool _menuOpened = false;
  bool _isDraggingMenu = false;

  double _drawerWidth = 0.66;
  double _minScale = 0.86;
  double _borderRadius = 32.0;
  double _shadowBorderRadius = 44.0;
  double _shadowOffset = 16.0;
  bool _scrollable = false;
  bool _disableContentTap = true;

  late Animation<double> animation, scaleAnimation;
  late Animation<BorderRadius?> radiusAnimation;
  late AnimationController animationController;

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
    if (widget.controller?.items != null) {
      return widget.controller!.items.map((KFDrawerItem item) {
        if (item.onPressed == null) {
          item.onPressed = () {
            widget.controller!.page = item.page;
            if (widget.controller!.close != null) widget.controller!.close!();
          };
        }
        item.page?.onMenuPressed = _onMenuPressed;
        return item;
      }).toList();
    }
    return widget.items;
  }

  @override
  void initState() {
    super.initState();
    if (widget.minScale != null) {
      _minScale = widget.minScale!;
    }
    if (widget.borderRadius != null) {
      _borderRadius = widget.borderRadius!;
    }
    if (widget.shadowOffset != null) {
      _shadowOffset = widget.shadowOffset!;
    }
    if (widget.shadowBorderRadius != null) {
      _shadowBorderRadius = widget.shadowBorderRadius!;
    }
    if (widget.drawerWidth != null) {
      _drawerWidth = widget.drawerWidth!;
    }
    if (widget.scrollable) {
      _scrollable = widget.scrollable;
    }
    if (widget.disableContentTap) {
      _disableContentTap = widget.disableContentTap;
    }
    animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController)
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
      });

    scaleAnimation = Tween<double>(begin: 1.0, end: _minScale).animate(animationController);
    radiusAnimation = BorderRadiusTween(begin: BorderRadius.circular(0.0), end: BorderRadius.circular(_borderRadius))
        .animate(CurvedAnimation(parent: animationController, curve: Curves.ease));
  }

  @override
  Widget build(BuildContext context) {
    widget.controller?.page?.onMenuPressed = _onMenuPressed;
    widget.controller?.close = _close;
    widget.controller?.open = _open;

    return Listener(
      onPointerDown: (PointerDownEvent event) {
        if (_disableContentTap) {
          if (_menuOpened && event.position.dx / MediaQuery.of(context).size.width >= _drawerWidth) {
            _close();
          } else {
            setState(() {
              _isDraggingMenu = (!_menuOpened && event.position.dx <= 8.0);
            });
          }
        } else {
          setState(() {
            _isDraggingMenu = (_menuOpened && event.position.dx / MediaQuery.of(context).size.width >= _drawerWidth) ||
                (!_menuOpened && event.position.dx <= 8.0);
          });
        }
      },
      onPointerMove: (PointerMoveEvent event) {
        if (_isDraggingMenu) {
          animationController.value = event.position.dx / MediaQuery.of(context).size.width;
        }
      },
      onPointerUp: (PointerUpEvent event) {
        _finishDrawerAnimation();
      },
      onPointerCancel: (PointerCancelEvent event) {
        _finishDrawerAnimation();
      },
      child: Stack(
        children: <Widget>[
          _KFDrawer(
            padding: widget.menuPadding,
            scrollable: _scrollable,
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
              child: AbsorbPointer(
                absorbing: _menuOpened && _disableContentTap,
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(_shadowBorderRadius)),
                              child: Container(
                                color: Colors.white.withAlpha(128),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: animation.value * _shadowOffset),
                      child: ClipRRect(
                        borderRadius: radiusAnimation.value ?? BorderRadius.zero,
                        child: Container(
                          color: Colors.white,
                          child: widget.controller?.page,
                        ),
                      ),
                    ),
                  ],
                ),
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
  _KFDrawer({
    Key? key,
    this.animationController,
    this.header,
    this.footer,
    this.items = const [],
    this.decoration,
    this.scrollable = true,
    this.padding,
  }) : super(key: key);

  Widget? header;
  Widget? footer;
  List<KFDrawerItem> items;
  BoxDecoration? decoration;
  bool scrollable;
  EdgeInsets? padding;

  Animation<double>? animationController;

  @override
  __KFDrawerState createState() => __KFDrawerState();
}

class __KFDrawerState extends State<_KFDrawer> {
  var _padding = EdgeInsets.symmetric(vertical: 64.0);

  Widget _getMenu() {
    if (widget.scrollable) {
      return ListView(
        children: [
          Container(
            child: widget.header,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.items,
          ),
          if (widget.footer != null) widget.footer!,
        ],
      );
    } else {
      return Column(
        children: [
          Container(
            child: widget.header,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.items,
            ),
          ),
          if (widget.footer != null) widget.footer!,
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.padding != null) {
      _padding = widget.padding!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.decoration,
      child: Padding(
        padding: _padding,
        child: _getMenu(),
      ),
    );
  }
}

class KFDrawerItem extends StatelessWidget {
  KFDrawerItem({this.onPressed, this.text, this.icon});

  KFDrawerItem.initWithPage({this.onPressed, this.text, this.icon, this.alias, this.page});

  GestureTapCallback? onPressed;
  Widget? text;
  Widget? icon;

  String? alias;
  KFDrawerContent? page;

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
                if (text != null) text!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
