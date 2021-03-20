import 'package:flutter/material.dart';

class SettingsItem extends StatefulWidget {
  const SettingsItem({
    Key key,
    @required this.settingTitle,
    @required this.modifyableWidget,
  }) : super(key: key);

  final String settingTitle; //Title of the setting
  final Widget modifyableWidget; //The Widget the user will interact with

  @override
  _SettingsItemState createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Colors.grey[300],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.settingTitle,
                style: TextStyle(fontSize: 20),
              ),
              widget.modifyableWidget,
            ],
          ),
        ),
      ),
    );
  }
}
