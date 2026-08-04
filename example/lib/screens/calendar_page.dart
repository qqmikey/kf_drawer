import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF5C8FF),
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
                  'Calendar',
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
