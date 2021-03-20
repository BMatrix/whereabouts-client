import 'dart:async';

import 'package:flutter/material.dart';
import 'package:whereabouts_client/components/settings_item.dart';
import 'package:whereabouts_client/services/preferences.dart';

enum SettingsAnimationState {
  open,
  mid,
  closed,
}

class Settings extends StatefulWidget {
  const Settings({
    Key key,
  }) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  SettingsAnimationState animationState = SettingsAnimationState.closed; //State of the settings panel
  Duration animationSpeed = Duration(); //Time it takes for the settings panel to do an animation
  TextEditingController serverIPTextFieldController = TextEditingController(); //Controlls the text field n stuff
  TextEditingController serverPortTextFieldController = TextEditingController(); //Controlls the text field n stuff
  final List<int> secondOptions = [5, 10, 20, 30, 60, 120, 300, 600]; //Options available in the time DropdownButtons
  final double floatingActionButtonSize = 56.2; //Size of the FloatingActionButton. Used for the layout of the panel
  final settingsBorderWidth = 4; //Width of settings panel border

  //Load text fields
  @override
  void initState() {
    super.initState();
    setTextFields();
  }

  //Converts secondOptions into a human readable format
  String getTimeString(int value) {
    if (value < 60) {
      return "$value seconds";
    } else {
      double minutes = value / 60;
      return "${minutes.toStringAsFixed(minutes.truncateToDouble() == minutes ? 0 : 1)} minutes";
    }
  }

  //Load the value from Preferences into the TextFields
  void setTextFields() {
    serverIPTextFieldController.text = Preferences.preferenceValues["serverIp"];
    serverPortTextFieldController.text = Preferences.preferenceValues["serverPort"].toString();
  }

  //Takes the current animationState and returns the desired settings panel size
  double getSettingsSize(String direction, double max) {
    if (animationState == SettingsAnimationState.closed) {
      return 56.2;
    } else if (animationState == SettingsAnimationState.mid) {
      if (direction == "width") {
        return max;
      } else {
        return 56.2;
      }
    } else {
      //SettingsAnimationState.open
      return max;
    }
  }

  //Opens/ closes the settings panel with some delay for the animations to play
  void openCloseSettings() {
    if (animationState == SettingsAnimationState.closed) {
      setState(() {
        animationSpeed = Duration(milliseconds: 300);
        animationState = SettingsAnimationState.mid;
      });
      Timer(Duration(milliseconds: 300), () {
        setState(() {
          animationSpeed = Duration(milliseconds: 200);
          animationState = SettingsAnimationState.open;
        });
      });
    }

    if (animationState == SettingsAnimationState.open) {
      setState(() {
        animationSpeed = Duration(milliseconds: 200);
        animationState = SettingsAnimationState.mid;
      });
      Timer(Duration(milliseconds: 200), () {
        setState(() {
          animationSpeed = Duration(milliseconds: 300);
          animationState = SettingsAnimationState.closed;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        //LayoutBuilder is used to get the constraints that show the max size the settings window is allowed to be
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            //AnimatedContainer
            return AnimatedContainer(
              duration: animationSpeed,
              curve: Curves.easeInOut,
              width: getSettingsSize("width", constraints.maxWidth),
              height: getSettingsSize("height", constraints.maxHeight),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[500],
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(floatingActionButtonSize / 2),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular((floatingActionButtonSize / 2) - settingsBorderWidth),
                child: Material(
                  color: Colors.transparent,
                  child:

                      //Settings List
                      ListView(
                    children: [
                      //All of these SizedBoxes could probably be replaced by using a ListView.seperated but I couldn't be bothered
                      SizedBox(
                        height: 10,
                      ),

                      //Title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 2, 0, 10),
                        child: Text(
                          "Settings",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      SettingsItem(
                        settingTitle: "Update your position every: ",
                        modifyableWidget: DropdownButton(
                          value: Preferences.preferenceValues["updatePositionTime"],
                          items: secondOptions.map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(getTimeString(value)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              Preferences.preferenceValues["updatePositionTime"] = value;
                            });
                            Preferences.setPreferences();
                          },
                        ),
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      SettingsItem(
                        settingTitle: "Request friend positions every: ",
                        modifyableWidget: DropdownButton(
                          value: Preferences.preferenceValues["getPositionTime"],
                          items: secondOptions.map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(getTimeString(value)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              Preferences.preferenceValues["getPositionTime"] = value;
                            });
                            Preferences.setPreferences();
                          },
                        ),
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      SettingsItem(
                        settingTitle: "Server IP: ",
                        modifyableWidget: TextField(
                          controller: serverIPTextFieldController,
                          onChanged: (value) {
                            Preferences.preferenceValues["serverIp"] = value;
                            Preferences.setPreferences();
                          },
                        ),
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      SettingsItem(
                        settingTitle: "Server Port: ",
                        modifyableWidget: TextField(
                          controller: serverPortTextFieldController,
                          onChanged: (value) {
                            Preferences.preferenceValues["serverPort"] = int.parse(value);
                            Preferences.setPreferences();
                          },
                        ),
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      SettingsItem(
                        settingTitle: "Reset settings to default values",
                        modifyableWidget: ElevatedButton(
                          child: Text("Reset"),
                          onPressed: () {
                            setState(() {
                              Preferences.resetPreferences();
                              setTextFields();
                            });
                          },
                        ),
                      ),

                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        FloatingActionButton(
          backgroundColor: Colors.grey,
          child: Icon(Icons.settings),
          onPressed: () {
            openCloseSettings();
          },
        ),
      ],
    );
  }
}
