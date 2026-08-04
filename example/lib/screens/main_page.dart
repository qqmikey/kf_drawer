import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ExamplePage(
      backgroundColor: Color(0xFFC8E2FF),
      label: 'Main',
    );
  }
}

class _ExamplePage extends StatelessWidget {
  const _ExamplePage({required this.backgroundColor, required this.label});

  final Color backgroundColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => KFDrawer.of(context)?.toggle(),
                tooltip: 'Open navigation menu',
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
