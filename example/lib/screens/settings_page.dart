import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';

// ignore: must_be_immutable
class SettingsPage extends StatefulWidget{
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFC8C8FF),
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
                      child: IconButton(icon: Icon(Icons.menu, color: Colors.black), onPressed:  () => KFDrawer.of(context)?.toggle()),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text('Settings')]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
