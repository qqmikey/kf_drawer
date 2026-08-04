import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';

import 'screens/auth_page.dart';
import 'screens/calendar_page.dart';
import 'screens/main_page.dart';
import 'screens/settings_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainWidget(),
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2C48AB),
        useMaterial3: true,
      ),
    );
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  late final KFDrawerController _drawerController;

  @override
  void initState() {
    super.initState();
    _drawerController = KFDrawerController(
      initialPage: const MainPage(),
      maintainPageHistory: true,
      items: <KFDrawerItem>[
        KFDrawerItem.withPage(
          alias: 'main',
          icon: const Icon(Icons.home, color: Colors.white),
          page: const MainPage(),
          text: const Text('MAIN', style: TextStyle(color: Colors.white)),
        ),
        KFDrawerItem.withPage(
          alias: 'calendar',
          icon: const Icon(Icons.calendar_today, color: Colors.white),
          page: const CalendarPage(),
          text: const Text('CALENDAR', style: TextStyle(color: Colors.white)),
        ),
        KFDrawerItem.withPage(
          alias: 'settings',
          icon: const Icon(Icons.settings, color: Colors.white),
          page: const SettingsPage(),
          text: const Text('SETTINGS', style: TextStyle(color: Colors.white)),
        ),
      ],
    )..addListener(_handleControllerChanged);
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !_drawerController.canGoBack,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _drawerController.goBack();
        }
      },
      child: Scaffold(
        body: KFDrawer(
          animationDuration: const Duration(milliseconds: 280),
          centerScrollableItems: true,
          controller: _drawerController,
          footer: KFDrawerItem(
            icon: const Icon(Icons.login, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute<void>(
                  builder: (context) => const AuthPage(),
                  fullscreenDialog: true,
                ),
              );
            },
            text: const Text('SIGN IN', style: TextStyle(color: Colors.white)),
          ),
          footerPinned: true,
          header: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Image.asset(
              'assets/logo.png',
              alignment: AlignmentDirectional.centerStart,
              width: 180,
            ),
          ),
          semanticLabel: 'Example navigation menu',
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              colors: <Color>[Color(0xFFFFFFFF), Color(0xFF2C48AB)],
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _drawerController
      ..removeListener(_handleControllerChanged)
      ..dispose();
    super.dispose();
  }
}
