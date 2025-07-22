library kf_drawer;

export 'kf_drawer_item.dart';
export 'kf_drawer_controller.dart';

import 'package:flutter/material.dart';
import 'kf_drawer_item.dart';
import 'kf_drawer_controller.dart';

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
    this.animationDuration = const Duration(milliseconds: 280),
    this.slideCurve = Curves.easeInOutCubic,
    this.scaleCurve = Curves.easeInOutBack,
  }) : super(key: key);

  final Widget? header;
  final Widget? footer;
  final BoxDecoration? decoration;
  final List<KFDrawerItem> items;
  final KFDrawerController? controller;
  final double? drawerWidth;
  final double? minScale;
  final double? borderRadius;
  final double? shadowBorderRadius;
  final double? shadowOffset;
  final bool scrollable;
  final EdgeInsets? menuPadding;
  final bool disableContentTap;
  final Duration animationDuration;
  final Curve slideCurve;
  final Curve scaleCurve;

  static _KFDrawerState? of(BuildContext context) {
    final _KFDrawerInherited? inherited = context.dependOnInheritedWidgetOfExactType<_KFDrawerInherited>();
    return inherited?.drawerState;
  }

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

  List<KFDrawerItem> _getDrawerItems(BuildContext context) {
    final controller = widget.controller;
    final items = controller?.items ?? widget.items;
    return items;
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
    animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: widget.slideCurve),
    )..addListener(() {
        setState(() {});
      });
    scaleAnimation = Tween<double>(begin: 1.0, end: _minScale).animate(
      CurvedAnimation(parent: animationController, curve: widget.scaleCurve),
    );
    radiusAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(0.0),
      end: BorderRadius.circular(_borderRadius),
    ).animate(CurvedAnimation(parent: animationController, curve: Curves.ease));

    widget.controller?.open = _open;
    widget.controller?.close = _close;
    widget.controller?.toggle = toggle;
  }

  @override
  Widget build(BuildContext context) {
    return _KFDrawerInherited(
      drawerState: this,
      child: Listener(
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
              _isDraggingMenu =
                  (_menuOpened && event.position.dx / MediaQuery.of(context).size.width >= _drawerWidth) ||
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
              items: _getDrawerItems(context),
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
      ),
    );
  }

  void close() => _close();

  void open() => _open();

  void toggle() => _menuOpened ? _close() : _open();

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class _KFDrawerInherited extends InheritedWidget {
  final _KFDrawerState drawerState;

  const _KFDrawerInherited({required Widget child, required this.drawerState}) : super(child: child);

  @override
  bool updateShouldNotify(_KFDrawerInherited oldWidget) => false;
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

  final Widget? header;
  final Widget? footer;
  final List<KFDrawerItem> items;
  final BoxDecoration? decoration;
  final bool scrollable;
  final EdgeInsets? padding;

  final AnimationController? animationController;

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
