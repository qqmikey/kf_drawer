/// An animated, controller-driven side drawer for Flutter applications.
library;

import 'package:flutter/material.dart';

import 'kf_drawer_controller.dart';
import 'kf_drawer_item.dart';

export 'kf_drawer_controller.dart';
export 'kf_drawer_item.dart';

/// Logical side from which a drawer opens.
///
/// [start] is left in LTR layouts and right in RTL layouts. [end] resolves to
/// the opposite physical side.
enum KFDrawerDirection {
  /// Opens from the start side of the ambient text direction.
  start,

  /// Opens from the end side of the ambient text direction.
  end,
}

/// Operations exposed by [KFDrawer.of] to descendants of a drawer.
abstract interface class KFDrawerControl {
  /// Whether the drawer is targeting its open state.
  bool get isOpen;

  /// Closes the drawer.
  void close();

  /// Opens the drawer.
  void open();

  /// Displays [page] through the attached [KFDrawerController].
  void setPage(Widget page);

  /// Opens a closed drawer or closes an open drawer.
  void toggle();
}

/// A side menu that translates and scales its content to reveal drawer items.
class KFDrawer extends StatefulWidget {
  /// Creates an animated side drawer.
  const KFDrawer({
    super.key,
    this.header,
    this.footer,
    this.content,
    this.direction = KFDrawerDirection.start,
    this.items = const <KFDrawerItem>[],
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
    this.dragEnabled = true,
    this.edgeDragWidth = 8,
    this.animationDuration = const Duration(milliseconds: 280),
    this.slideCurve = Curves.easeInOutCubic,
    this.scaleCurve = Curves.easeInOutBack,
    this.onDrawerChanged,
    this.semanticLabel,
    this.shadowColor = const Color(0x80FFFFFF),
    this.footerPinned = false,
    this.centerScrollableItems = false,
  })  : assert(drawerWidth == null || drawerWidth > 0 && drawerWidth <= 1),
        assert(minScale == null || minScale >= 0 && minScale <= 1),
        assert(borderRadius == null || borderRadius >= 0),
        assert(shadowBorderRadius == null || shadowBorderRadius >= 0),
        assert(edgeDragWidth >= 0);

  /// Optional widget displayed above the menu items.
  final Widget? header;

  /// Optional widget displayed after or below the menu items.
  final Widget? footer;

  /// Content displayed when [controller] is null or has no current page.
  final Widget? content;

  /// Logical side from which the drawer opens.
  final KFDrawerDirection direction;

  /// Background decoration for the drawer layer.
  final BoxDecoration? decoration;

  /// Items used when [controller] is null.
  final List<KFDrawerItem> items;

  /// Controller that supplies the current page and, when non-null, the items.
  final KFDrawerController? controller;

  /// Revealed drawer width as a fraction of the available screen width.
  final double? drawerWidth;

  /// Scale applied to content while the drawer is fully open.
  final double? minScale;

  /// Content corner radius while the drawer is fully open.
  final double? borderRadius;

  /// Corner radius of the decorative shadow layer.
  final double? shadowBorderRadius;

  /// Horizontal offset of the decorative shadow layer.
  final double? shadowOffset;

  /// Whether drawer items can scroll.
  final bool scrollable;

  /// Padding around the drawer menu.
  final EdgeInsets? menuPadding;

  /// Whether open drawer content absorbs taps and closes when tapped.
  final bool disableContentTap;

  /// Whether horizontal pointer dragging can open and close the drawer.
  final bool dragEnabled;

  /// Width of the edge gesture area used to start opening a closed drawer.
  final double edgeDragWidth;

  /// Duration of programmatic open and close animations.
  final Duration animationDuration;

  /// Curve used for content translation.
  final Curve slideCurve;

  /// Curve used for content scaling.
  final Curve scaleCurve;

  /// Called when the drawer starts targeting a different open state.
  final ValueChanged<bool>? onDrawerChanged;

  /// Accessibility label applied to the drawer menu while it is visible.
  final String? semanticLabel;

  /// Color of the decorative layer behind the transformed content.
  final Color shadowColor;

  /// Keeps [footer] outside the scrolling item list when enabled.
  final bool footerPinned;

  /// Vertically centers a shrink-wrapped scrollable item list.
  ///
  /// Enabling this also keeps [header] and [footer] outside the item list.
  final bool centerScrollableItems;

  /// Returns controls for the nearest ancestor [KFDrawer], if one exists.
  static KFDrawerControl? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_KFDrawerInherited>()
        ?.control;
  }

  @override
  State<KFDrawer> createState() => _KFDrawerState();
}

class _KFDrawerState extends State<KFDrawer>
    with SingleTickerProviderStateMixin
    implements KFDrawerControl {
  static const double _defaultDrawerWidth = 0.66;
  static const double _defaultMinScale = 0.86;
  static const double _defaultBorderRadius = 32;
  static const double _defaultShadowBorderRadius = 44;
  static const double _defaultShadowOffset = 16;

  bool _menuOpened = false;
  bool _isDraggingMenu = false;

  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<BorderRadius?> _radiusAnimation;
  late AnimationController _animationController;

  double get _drawerWidth => widget.drawerWidth ?? _defaultDrawerWidth;
  double get _minScale => widget.minScale ?? _defaultMinScale;
  double get _borderRadius => widget.borderRadius ?? _defaultBorderRadius;
  double get _shadowBorderRadius =>
      widget.shadowBorderRadius ?? _defaultShadowBorderRadius;
  double get _shadowOffset => widget.shadowOffset ?? _defaultShadowOffset;
  double get _translationProgress =>
      _isDraggingMenu ? _animationController.value : _slideAnimation.value;

  @override
  bool get isOpen => _menuOpened;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _configureAnimations();
    _attachController(widget.controller);
  }

  @override
  void didUpdateWidget(KFDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachController(oldWidget.controller);
      _attachController(widget.controller);
    }
    if (oldWidget.animationDuration != widget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }
    if (oldWidget.minScale != widget.minScale ||
        oldWidget.borderRadius != widget.borderRadius ||
        oldWidget.slideCurve != widget.slideCurve ||
        oldWidget.scaleCurve != widget.scaleCurve) {
      _configureAnimations();
    }
  }

  void _configureAnimations() {
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.slideCurve,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: _minScale).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.scaleCurve,
      ),
    );
    _radiusAnimation = BorderRadiusTween(
      begin: BorderRadius.zero,
      end: BorderRadius.circular(_borderRadius),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.ease,
      ),
    );
  }

  void _attachController(KFDrawerController? controller) {
    if (controller == null) {
      return;
    }
    controller
      ..addListener(_handleControllerChanged)
      ..open = open
      ..close = close
      ..toggle = toggle;
  }

  void _detachController(KFDrawerController? controller) {
    if (controller == null) {
      return;
    }
    controller
      ..removeListener(_handleControllerChanged)
      ..open = null
      ..close = null
      ..toggle = null;
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void open() {
    if (_menuOpened && !_isDraggingMenu) {
      return;
    }
    final changed = !_menuOpened;
    setState(() {
      _menuOpened = true;
      _isDraggingMenu = false;
    });
    if (changed) {
      widget.onDrawerChanged?.call(true);
    }
    _animationController.forward();
  }

  @override
  void close() {
    if (!_menuOpened && !_isDraggingMenu) {
      return;
    }
    final changed = _menuOpened;
    setState(() {
      _menuOpened = false;
      _isDraggingMenu = false;
    });
    if (changed) {
      widget.onDrawerChanged?.call(false);
    }
    _animationController.reverse();
  }

  @override
  void toggle() => _menuOpened ? close() : open();

  @override
  void setPage(Widget page) {
    widget.controller?.page = page;
  }

  void _finishDrawerAnimation() {
    if (!_isDraggingMenu) {
      return;
    }
    if (_animationController.value >= 0.4) {
      open();
    } else {
      close();
    }
  }

  List<KFDrawerItem> _getDrawerItems() {
    return widget.controller?.items ?? widget.items;
  }

  bool _opensFromLeft(BuildContext context) {
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    return widget.direction == KFDrawerDirection.start ? isLtr : !isLtr;
  }

  @override
  Widget build(BuildContext context) {
    return _KFDrawerInherited(
      control: this,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final screenWidth = MediaQuery.sizeOf(context).width;
          final drawerPixelWidth = screenWidth * _drawerWidth;
          final opensFromLeft = _opensFromLeft(context);
          return Listener(
            onPointerDown: (event) {
              final pointerOverContent = opensFromLeft
                  ? event.position.dx >= drawerPixelWidth
                  : event.position.dx <= screenWidth - drawerPixelWidth;
              if (widget.disableContentTap &&
                  _menuOpened &&
                  pointerOverContent) {
                close();
                return;
              }
              if (!widget.dragEnabled) {
                return;
              }
              setState(() {
                final pointerAtEdge = opensFromLeft
                    ? event.position.dx <= widget.edgeDragWidth
                    : event.position.dx >= screenWidth - widget.edgeDragWidth;
                _isDraggingMenu = widget.disableContentTap
                    ? !_menuOpened && pointerAtEdge
                    : (_menuOpened && pointerOverContent) ||
                        (!_menuOpened && pointerAtEdge);
              });
            },
            onPointerMove: (event) {
              if (_isDraggingMenu) {
                final progress = opensFromLeft
                    ? event.position.dx / drawerPixelWidth
                    : (screenWidth - event.position.dx) / drawerPixelWidth;
                _animationController.value =
                    progress.clamp(0.0, 1.0).toDouble();
              }
            },
            onPointerUp: (_) => _finishDrawerAnimation(),
            onPointerCancel: (_) => _finishDrawerAnimation(),
            child: Stack(
              children: <Widget>[
                ExcludeSemantics(
                  excluding: _animationController.value == 0,
                  child: IgnorePointer(
                    ignoring: !_menuOpened && !_isDraggingMenu,
                    child: Semantics(
                      container: true,
                      label: widget.semanticLabel ??
                          MaterialLocalizations.of(context).drawerLabel,
                      child: _KFDrawerMenu(
                        centerScrollableItems: widget.centerScrollableItems,
                        decoration: widget.decoration,
                        footer: widget.footer,
                        footerPinned: widget.footerPinned,
                        header: widget.header,
                        items: _getDrawerItems(),
                        opensFromLeft: opensFromLeft,
                        padding: widget.menuPadding,
                        scrollable: widget.scrollable,
                        widthFactor: _drawerWidth,
                      ),
                    ),
                  ),
                ),
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.translate(
                    offset: Offset(
                      drawerPixelWidth *
                          _translationProgress *
                          (opensFromLeft ? 1 : -1),
                      0,
                    ),
                    child: AbsorbPointer(
                      absorbing: _menuOpened && widget.disableContentTap,
                      child: Stack(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 32,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(_shadowBorderRadius),
                                    ),
                                    child: Container(
                                      color: widget.shadowColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: opensFromLeft
                                ? EdgeInsets.only(
                                    left: _translationProgress * _shadowOffset,
                                  )
                                : EdgeInsets.only(
                                    right: _translationProgress * _shadowOffset,
                                  ),
                            child: ClipRRect(
                              borderRadius:
                                  _radiusAnimation.value ?? BorderRadius.zero,
                              child: ColoredBox(
                                color: Colors.white,
                                child: SizedBox.expand(
                                  child: widget.controller?.page ??
                                      widget.content ??
                                      const SizedBox.shrink(),
                                ),
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
        },
      ),
    );
  }

  @override
  void dispose() {
    _detachController(widget.controller);
    _animationController.dispose();
    super.dispose();
  }
}

class _KFDrawerInherited extends InheritedWidget {
  const _KFDrawerInherited({
    required this.control,
    required super.child,
  });

  final KFDrawerControl control;

  @override
  bool updateShouldNotify(_KFDrawerInherited oldWidget) => false;
}

class _KFDrawerMenu extends StatelessWidget {
  const _KFDrawerMenu({
    required this.centerScrollableItems,
    required this.footerPinned,
    required this.items,
    required this.opensFromLeft,
    required this.scrollable,
    required this.widthFactor,
    this.header,
    this.footer,
    this.decoration,
    this.padding,
  });

  final Widget? header;
  final Widget? footer;
  final List<KFDrawerItem> items;
  final BoxDecoration? decoration;
  final bool centerScrollableItems;
  final bool footerPinned;
  final bool opensFromLeft;
  final bool scrollable;
  final double widthFactor;
  final EdgeInsets? padding;

  Widget _getMenu() {
    if (scrollable) {
      if (centerScrollableItems) {
        return Column(
          children: <Widget>[
            if (header != null) header!,
            Expanded(
              child: Center(
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: items,
                ),
              ),
            ),
            if (footer != null) footer!,
          ],
        );
      }
      if (footerPinned) {
        return Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  if (header != null) header!,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: items,
                  ),
                ],
              ),
            ),
            if (footer != null) footer!,
          ],
        );
      }
      return ListView(
        children: <Widget>[
          if (header != null) header!,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items,
          ),
          if (footer != null) footer!,
        ],
      );
    }
    return Column(
      children: <Widget>[
        if (header != null) header!,
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items,
          ),
        ),
        if (footer != null) footer!,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: decoration ?? const BoxDecoration(),
      child: Align(
        alignment: opensFromLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(vertical: 64),
            child: _getMenu(),
          ),
        ),
      ),
    );
  }
}
