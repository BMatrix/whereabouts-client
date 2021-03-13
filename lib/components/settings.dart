import 'dart:async';

import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({
    Key key,
  }) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int options = 0;
  Duration animationSpeed = Duration(milliseconds: 500);

  double getSettingsSize(String direction, double max) {
    if (options == 0)
      return 55;
    else if (options == 1) {
      if (direction == "width")
        return max;
      else
        return 55;
    } else
      return max;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return AnimatedContainer(
              duration: animationSpeed,
              curve: Curves.easeInOut,
              width: getSettingsSize("width", constraints.maxWidth),
              height: getSettingsSize("height", constraints.maxHeight),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(55 / 2),
                color: Colors.grey[200],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 55.0, 8.0, 8.0),
                child: ListView(
                  children: [],
                ),
              ),
            );
          },
        ),
        FloatingActionButton(
          backgroundColor: Colors.grey,
          child: Icon(Icons.settings),
          onPressed: () {
            if (options == 0) {
              setState(() {
                animationSpeed = Duration(milliseconds: 500);
                options = 1;
              });
              Timer(
                Duration(milliseconds: 500),
                () {
                  setState(() {
                    animationSpeed = Duration(milliseconds: 200);
                    options = 2;
                  });
                },
              );
            }
            if (options == 2) {
              setState(() {
                animationSpeed = Duration(milliseconds: 200);
                options = 1;
              });
              Timer(Duration(milliseconds: 200), () {
                setState(() {
                  animationSpeed = Duration(milliseconds: 500);
                  options = 0;
                });
              });
            }
          },
        ),
      ],
    );
  }
}
