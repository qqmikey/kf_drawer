import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';

class CalendarPage extends KFDrawerContent {
  CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF5C8FF),
      child: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    child: Material(
                      shadowColor: Colors.transparent,
                      color: Colors.transparent,
                      child: IconButton(icon: Icon(Icons.menu, color: Colors.black), onPressed: widget.onMenuPressed),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text('Calendar')]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
