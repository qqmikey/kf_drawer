import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kf_drawer/kf_drawer.dart';

const _instantAnimation = Duration.zero;

Widget _testApp({
  KFDrawerController? controller,
  Widget? content,
  bool disableContentTap = true,
  bool dragEnabled = true,
  double edgeDragWidth = 8,
  bool centerScrollableItems = false,
  KFDrawerDirection direction = KFDrawerDirection.start,
  Widget? footer,
  bool footerPinned = false,
  Widget? header,
  List<KFDrawerItem> items = const <KFDrawerItem>[],
  double? minScale,
  ValueChanged<bool>? onDrawerChanged,
  String? semanticLabel,
  double? shadowOffset,
  bool scrollable = true,
  TextDirection textDirection = TextDirection.ltr,
}) {
  return MaterialApp(
    home: Directionality(
      textDirection: textDirection,
      child: Scaffold(
        body: KFDrawer(
          animationDuration: _instantAnimation,
          centerScrollableItems: centerScrollableItems,
          content: content,
          controller: controller,
          direction: direction,
          disableContentTap: disableContentTap,
          dragEnabled: dragEnabled,
          edgeDragWidth: edgeDragWidth,
          footer: footer,
          footerPinned: footerPinned,
          header: header,
          items: items,
          minScale: minScale,
          onDrawerChanged: onDrawerChanged,
          semanticLabel: semanticLabel,
          shadowOffset: shadowOffset,
          scrollable: scrollable,
        ),
      ),
    ),
  );
}

void main() {
  group('controller', () {
    test('items can be added removed and cleared dynamically', () {
      const first = KFDrawerItem(text: Text('First'));
      const second = KFDrawerItem(text: Text('Second'));
      final controller = KFDrawerController(
        initialPage: const SizedBox(),
      );
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.addItem(first);
      controller.addItem(second);
      expect(controller.items, <KFDrawerItem>[first, second]);

      expect(controller.removeItem(first), isTrue);
      expect(controller.removeItem(first), isFalse);
      controller.clearItems();

      expect(controller.items, isEmpty);
      expect(notifications, 4);
    });

    test('items setter copies immutable input and notifies listeners', () {
      const item = KFDrawerItem(text: Text('Item'));
      final controller = KFDrawerController(
        initialPage: const SizedBox(),
      );
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.items = const <KFDrawerItem>[item];
      controller.addItem(const KFDrawerItem(text: Text('Another')));

      expect(controller.items, hasLength(2));
      expect(notifications, 2);
    });

    test('legacy Function callbacks remain assignable', () {
      final controller = KFDrawerController(
        initialPage: const SizedBox(),
      );
      var opened = false;
      // Keep the broad legacy type to verify the 2.0 public field contract.
      // ignore: prefer_function_declarations_over_variables
      final Function legacyOpen = () => opened = true;

      controller.open = legacyOpen;
      controller.open?.call();

      expect(opened, isTrue);
    });

    test('item alias selects its page', () {
      const aliasedPage = SizedBox(key: Key('aliased-page'));
      final controller = KFDrawerController(
        initialPage: const SizedBox(),
        items: const <KFDrawerItem>[
          KFDrawerItem(alias: 'settings', page: aliasedPage),
          KFDrawerItem(alias: 'missing-page'),
        ],
      );

      expect(controller.selectItem('settings'), isTrue);
      expect(controller.page, same(aliasedPage));
      expect(controller.selectItem('missing-page'), isFalse);
      expect(controller.selectItem('unknown'), isFalse);
    });

    test('opt-in page history restores prior pages', () {
      const first = SizedBox(key: Key('first'));
      const second = SizedBox(key: Key('second'));
      const third = SizedBox(key: Key('third'));
      final controller = KFDrawerController(
        initialPage: first,
        maintainPageHistory: true,
      );

      controller.page = second;
      controller.page = third;

      expect(controller.canGoBack, isTrue);
      expect(controller.goBack(), isTrue);
      expect(controller.page, same(second));
      expect(controller.goBack(), isTrue);
      expect(controller.page, same(first));
      expect(controller.goBack(), isFalse);
      expect(controller.canGoBack, isFalse);
    });

    test('replacePage and clearHistory do not create back entries', () {
      const first = SizedBox(key: Key('first'));
      const second = SizedBox(key: Key('second'));
      const third = SizedBox(key: Key('third'));
      final controller = KFDrawerController(
        initialPage: first,
        maintainPageHistory: true,
      );

      controller.replacePage(second);
      expect(controller.canGoBack, isFalse);
      controller.page = third;
      expect(controller.canGoBack, isTrue);
      controller.clearHistory();

      expect(controller.canGoBack, isFalse);
    });
  });

  group('lifecycle and reactive configuration', () {
    testWidgets('disableContentTap false keeps content interactive while open',
        (tester) async {
      var taps = 0;
      final controller = KFDrawerController(
        initialPage: GestureDetector(
          key: const Key('interactive-content'),
          behavior: HitTestBehavior.opaque,
          onTap: () => taps++,
          child: const SizedBox.expand(),
        ),
      );
      await tester.pumpWidget(
        _testApp(
          controller: controller,
          disableContentTap: false,
        ),
      );

      controller.open?.call();
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(700, 300));

      expect(taps, 1);
    });

    testWidgets('scrollable reacts to widget configuration updates',
        (tester) async {
      final controller = KFDrawerController(
        initialPage: const ColoredBox(color: Colors.white),
      );
      await tester.pumpWidget(_testApp(controller: controller));
      expect(find.byType(ListView), findsOneWidget);

      await tester.pumpWidget(
        _testApp(controller: controller, scrollable: false),
      );

      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('replacement controller is attached and old one is detached',
        (tester) async {
      final first = KFDrawerController(
        initialPage: const ColoredBox(color: Colors.white),
      );
      final second = KFDrawerController(
        initialPage: const ColoredBox(color: Colors.black),
      );
      await tester.pumpWidget(_testApp(controller: first));
      expect(first.open, isNotNull);

      await tester.pumpWidget(_testApp(controller: second));

      expect(first.open, isNull);
      expect(first.close, isNull);
      expect(first.toggle, isNull);
      expect(second.open, isNotNull);
      expect(second.close, isNotNull);
      expect(second.toggle, isNotNull);
    });

    testWidgets('controller callbacks are cleared when drawer is disposed',
        (tester) async {
      final controller = KFDrawerController(
        initialPage: const ColoredBox(color: Colors.white),
      );
      await tester.pumpWidget(_testApp(controller: controller));
      expect(controller.open, isNotNull);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(controller.open, isNull);
      expect(controller.close, isNull);
      expect(controller.toggle, isNull);
    });
  });

  group('control and interaction', () {
    testWidgets('open close and toggle report state changes', (tester) async {
      final states = <bool>[];
      final controller = KFDrawerController(
        initialPage: const ColoredBox(color: Colors.white),
      );
      await tester.pumpWidget(
        _testApp(
          controller: controller,
          onDrawerChanged: states.add,
        ),
      );

      controller.open?.call();
      await tester.pumpAndSettle();
      controller.toggle?.call();
      await tester.pumpAndSettle();
      controller.toggle?.call();
      await tester.pumpAndSettle();
      controller.close?.call();
      await tester.pumpAndSettle();

      expect(states, <bool>[true, false, true, false]);
    });

    testWidgets('custom content works without a controller', (tester) async {
      await tester.pumpWidget(
        _testApp(
          content: const ColoredBox(
            key: Key('custom-content'),
            color: Colors.orange,
          ),
        ),
      );

      expect(find.byKey(const Key('custom-content')), findsOneWidget);
    });

    testWidgets('page item composes selection with onPressed', (tester) async {
      var pressed = 0;
      const secondPage = ColoredBox(
        key: Key('second-page'),
        color: Colors.black,
      );
      final item = KFDrawerItem(
        text: const Text('Second'),
        page: secondPage,
        onPressed: () => pressed++,
      );
      final controller = KFDrawerController(
        initialPage: const ColoredBox(color: Colors.white),
        items: <KFDrawerItem>[item],
      );
      await tester.pumpWidget(_testApp(controller: controller));
      controller.open?.call();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();

      expect(pressed, 1);
      expect(controller.page, same(secondPage));
      expect(find.byKey(const Key('second-page')), findsOneWidget);
    });

    testWidgets('controller page assignment rebuilds without closing',
        (tester) async {
      final controller = KFDrawerController(
        initialPage: const ColoredBox(color: Colors.white),
      );
      await tester.pumpWidget(_testApp(controller: controller));

      controller.page = const ColoredBox(
        key: Key('assigned-page'),
        color: Colors.blue,
      );
      await tester.pump();

      expect(find.byKey(const Key('assigned-page')), findsOneWidget);
    });

    testWidgets('edge drag is normalized to the revealed drawer width',
        (tester) async {
      final controller = KFDrawerController(
        initialPage: const ColoredBox(
          key: Key('drag-content'),
          color: Colors.white,
        ),
      );
      await tester.pumpWidget(
        _testApp(controller: controller, minScale: 1, shadowOffset: 0),
      );

      final gesture = await tester.startGesture(const Offset(1, 300));
      await gesture.moveTo(const Offset(528, 300));
      await tester.pump();

      expect(
        tester.getTopLeft(find.byKey(const Key('drag-content'))).dx,
        closeTo(528, 1),
      );
      await gesture.up();
    });

    testWidgets('edge drag tracks the pointer before release', (tester) async {
      final controller = KFDrawerController(
        initialPage: const ColoredBox(
          key: Key('partial-drag-content'),
          color: Colors.white,
        ),
      );
      await tester.pumpWidget(
        _testApp(controller: controller, minScale: 1, shadowOffset: 0),
      );

      final gesture = await tester.startGesture(const Offset(1, 300));
      await gesture.moveTo(const Offset(132, 300));
      await tester.pump();

      expect(
        tester.getTopLeft(find.byKey(const Key('partial-drag-content'))).dx,
        closeTo(132, 1),
      );
      await gesture.up();
    });

    testWidgets('drag can be disabled', (tester) async {
      final controller = KFDrawerController(
        initialPage: const ColoredBox(
          key: Key('fixed-content'),
          color: Colors.white,
        ),
      );
      await tester.pumpWidget(
        _testApp(controller: controller, dragEnabled: false, minScale: 1),
      );

      await tester.dragFrom(const Offset(1, 300), const Offset(500, 0));
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.byKey(const Key('fixed-content'))).dx,
        0,
      );
    });

    testWidgets('disabling drag does not disable content-tap close',
        (tester) async {
      final states = <bool>[];
      final controller = KFDrawerController(
        initialPage: const ColoredBox(color: Colors.white),
      );
      await tester.pumpWidget(
        _testApp(
          controller: controller,
          dragEnabled: false,
          onDrawerChanged: states.add,
        ),
      );
      controller.open?.call();
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(700, 300));
      await tester.pumpAndSettle();

      expect(states, <bool>[true, false]);
    });

    testWidgets('closeOnTap false keeps the selected page drawer open',
        (tester) async {
      final states = <bool>[];
      const nextPage = ColoredBox(color: Colors.blue);
      final controller = KFDrawerController(
        initialPage: const ColoredBox(color: Colors.white),
        items: const <KFDrawerItem>[
          KFDrawerItem(
            closeOnTap: false,
            page: nextPage,
            text: Text('Keep open'),
          ),
        ],
      );
      await tester.pumpWidget(
        _testApp(
          controller: controller,
          onDrawerChanged: states.add,
        ),
      );
      controller.open?.call();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keep open'));
      await tester.pumpAndSettle();

      expect(controller.page, same(nextPage));
      expect(states, <bool>[true]);
    });

    testWidgets('closed drawer is excluded from semantics', (tester) async {
      final semantics = tester.ensureSemantics();
      final controller = KFDrawerController(
        initialPage: const ColoredBox(color: Colors.white),
        items: const <KFDrawerItem>[
          KFDrawerItem(text: Text('Semantic item')),
        ],
      );
      await tester.pumpWidget(
        _testApp(
          controller: controller,
          semanticLabel: 'Test navigation drawer',
        ),
      );

      expect(find.bySemanticsLabel('Test navigation drawer'), findsNothing);
      controller.open?.call();
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel('Test navigation drawer'),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('dynamic controller items rebuild the visible menu',
        (tester) async {
      const removedItem = KFDrawerItem(text: Text('Removed later'));
      final controller = KFDrawerController(
        initialPage: const ColoredBox(color: Colors.white),
        items: const <KFDrawerItem>[removedItem],
      );
      await tester.pumpWidget(
        _testApp(
          centerScrollableItems: true,
          controller: controller,
        ),
      );
      controller.open?.call();
      await tester.pumpAndSettle();
      expect(find.text('Removed later'), findsOneWidget);
      expect(find.text('Added later'), findsNothing);

      controller.addItem(
        const KFDrawerItem(text: Text('Added later')),
      );
      await tester.pump();

      expect(find.text('Added later'), findsOneWidget);

      expect(controller.removeItem(removedItem), isTrue);
      await tester.pump();

      expect(find.text('Removed later'), findsNothing);
      expect(find.text('Added later'), findsOneWidget);
    });
  });

  group('layout and direction', () {
    testWidgets('pinned footer stays outside the scrollable item list',
        (tester) async {
      final items = List<KFDrawerItem>.generate(
        20,
        (index) => KFDrawerItem(text: Text('Item $index')),
      );
      await tester.pumpWidget(
        _testApp(
          content: const ColoredBox(color: Colors.white),
          footer: const Text('Pinned footer', key: Key('footer')),
          footerPinned: true,
          items: items,
        ),
      );

      expect(
        find.ancestor(
          of: find.byKey(const Key('footer')),
          matching: find.byType(ListView),
        ),
        findsNothing,
      );
      expect(
        find.ancestor(
          of: find.text('Item 0'),
          matching: find.byType(ListView),
        ),
        findsOneWidget,
      );
    });

    testWidgets('scrollable items can be centered between header and footer',
        (tester) async {
      await tester.pumpWidget(
        _testApp(
          centerScrollableItems: true,
          content: const ColoredBox(color: Colors.white),
          footer: const Text('Footer'),
          header: const Text('Header'),
          items: const <KFDrawerItem>[
            KFDrawerItem(
              text: Text('Centered item', key: Key('centered-item')),
            ),
          ],
        ),
      );

      expect(
        find.ancestor(
          of: find.byKey(const Key('centered-item')),
          matching: find.byType(Center),
        ),
        findsOneWidget,
      );
      final listView = tester.widget<ListView>(
        find.ancestor(
          of: find.byKey(const Key('centered-item')),
          matching: find.byType(ListView),
        ),
      );
      expect(listView.shrinkWrap, isTrue);
    });

    testWidgets('end drawer opens from the right in LTR', (tester) async {
      final controller = KFDrawerController(
        initialPage: const ColoredBox(
          key: Key('end-content'),
          color: Colors.white,
        ),
        items: const <KFDrawerItem>[
          KFDrawerItem(text: Text('End item')),
        ],
      );
      await tester.pumpWidget(
        _testApp(
          controller: controller,
          direction: KFDrawerDirection.end,
          minScale: 1,
          shadowOffset: 0,
        ),
      );

      controller.open?.call();
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.byKey(const Key('end-content'))).dx,
        closeTo(-528, 1),
      );
      expect(tester.getCenter(find.text('End item')).dx, greaterThan(272));
    });

    testWidgets('start drawer follows RTL and opens from the right',
        (tester) async {
      final controller = KFDrawerController(
        initialPage: const ColoredBox(
          key: Key('rtl-content'),
          color: Colors.white,
        ),
      );
      await tester.pumpWidget(
        _testApp(
          controller: controller,
          minScale: 1,
          shadowOffset: 0,
          textDirection: TextDirection.rtl,
        ),
      );

      controller.open?.call();
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.byKey(const Key('rtl-content'))).dx,
        closeTo(-528, 1),
      );
    });

    testWidgets('end drawer supports edge drag from the right', (tester) async {
      final controller = KFDrawerController(
        initialPage: const ColoredBox(
          key: Key('right-drag-content'),
          color: Colors.white,
        ),
      );
      await tester.pumpWidget(
        _testApp(
          controller: controller,
          direction: KFDrawerDirection.end,
          minScale: 1,
          shadowOffset: 0,
        ),
      );

      final gesture = await tester.startGesture(const Offset(799, 300));
      await gesture.moveTo(const Offset(272, 300));
      await tester.pump();

      expect(
        tester.getTopLeft(find.byKey(const Key('right-drag-content'))).dx,
        closeTo(-528, 1),
      );
      await gesture.up();
    });
  });
}
