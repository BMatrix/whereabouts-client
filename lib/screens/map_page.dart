import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:whereabouts_client/components/marker_popup.dart';
import 'package:whereabouts_client/components/settings.dart';
import 'package:whereabouts_client/services/map_functions.dart';
import 'package:whereabouts_client/services/mock_location.dart';
import 'package:whereabouts_client/services/preferences.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapController mapController = MapController();
  PopupController _popupLayerController = PopupController();
  SettingsPanelController settingsController = SettingsPanelController();
  LatLng currentLocation;
  LatLng sharedCenter; //Center point of all shared locations and your own position
  bool sharedCenterEnable = false; //Enables visual sharedCenter on the map
  double sharedZoom; //Zoom level to use with the "center all" button
  List<Person> people = [];
  Person selectedPerson;
  //ToDo: change timers with background task
  Timer timer; //Own locations update timer
  Timer sharedTimer; //Shared locations get timer

  @override
  void initState() {
    super.initState();
    updatePosition(move: true);
    updateShared(move: true);

    timer = Timer.periodic(Duration(seconds: Preferences.preferenceValues["updatePositionTime"]), (t) => updatePosition());
    sharedTimer = Timer.periodic(Duration(seconds: Preferences.preferenceValues["getPositionTime"]), (t) => updateShared());
  }

  @override
  void dispose() {
    timer.cancel();
    sharedTimer.cancel();
    super.dispose();
  }

  //Get location, store it, move camera to your position if people are not loaded in
  void updatePosition({bool move: false}) {
    Geolocator.getCurrentPosition().then((position) {
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        if (move && people != null) {
          mapController.move(currentLocation, 15);
        }
      });
    });
  }

  void updateShared({bool move: false}) {
    //Get shared List<Person>
    MockLocation.getSharedLocations().then((people) {
      setState(() {
        this.people = people;

        //Set selectedPerson to keep MarkerPopup active
        if (selectedPerson != null) {
          for (Person person in people) {
            if (person.name == selectedPerson.name) {
              selectedPerson = person;
              getMarkers().forEach((marker) {
                if (marker.point == person.location) {
                  _popupLayerController.showPopupFor(marker);
                }
              });
              break;
            }
          }
        }

        //Set vars
        List<LatLng> locations = MapFunctions.peopleToLatLngs(people);
        if (currentLocation != null) {
          locations.add(currentLocation);
        }
        sharedCenter = MapFunctions.getSharedCenter(locations);
        sharedZoom = MapFunctions.getSharedZoom(locations);

        //Move to overview of all locations
        if (move) {
          mapController.move(sharedCenter, sharedZoom);
        }
      });
    });
  }

  Color getMarkerColor(Person person) {
    if (person == null) {
      return Colors.blue;
    } else {
      Duration timeSince = DateTime.now().difference(person.time);
      if (timeSince.inSeconds < Preferences.preferenceValues["getPositionTime"] * 3) {
        return Colors.green;
      } else {
        return Colors.grey;
      }
    }
  }

  List<Marker> getMarkers() {
    List<Marker> markers = [];

    //Current position
    if (currentLocation != null) {
      markers.add(
        Marker(
          width: 24,
          height: 24,
          point: currentLocation,
          builder: (ctx) => Container(
            child: Icon(
              Icons.radio_button_checked,
              color: Colors.blue,
              size: 24,
            ),
          ),
        ),
      );
    }

    //All shared locations
    for (Person person in people) {
      markers.add(
        Marker(
          width: 50,
          height: 50,
          point: person.location,
          anchorPos: AnchorPos.exactly(Anchor(25, 5)), //25: centers horizontally, 5 makes icon point to exact location
          builder: (_) => Container(
            child: Icon(
              Icons.person_pin,
              color: getMarkerColor(person),
              size: 50,
            ),
          ),
        ),
      );
    }

    //Visual sharedCenter on the map
    if (sharedCenterEnable && sharedCenter != null) {
      markers.add(
        Marker(
          point: sharedCenter,
          builder: (ctx) => Container(
            child: Icon(
              Icons.radio_button_checked,
              color: Colors.green,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Future<void> _showExitDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Leave Whereabouts?'),
          actions: <Widget>[
            TextButton(
              child: Text('Leave'),
              onPressed: () {
                SystemNavigator.pop();
                exit(0);
              },
            ),
            TextButton(
              child: Text('Stay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (settingsController.getPanelState() == SettingsPanelOperation.open) {
          settingsController.openCloseSettingsPanel(SettingsPanelOperation.close);
        } else {
          _showExitDialog();
        }
        return null;
      },
      child: Container(
        child: Stack(
          children: [
            //Background colors to fill up the missing map top and bottom
            Column(children: [
              Expanded(child: Container(color: Color(0xffabd3df))),
              Expanded(child: Container(color: Color(0xfff2efe8))),
            ]),

            //Map
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: LatLng(0, 0),
                zoom: 2.0,
                minZoom: 0, //Map dissapears if zoomed out too far
                maxZoom: 18, //Map dissapears if zoomed in too far
                interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate, //Disable map rotation
                plugins: [PopupMarkerPlugin()],
                onTap: (_) {
                  _popupLayerController.hidePopup();
                  selectedPerson = null;
                },
              ),
              layers: [
                TileLayerOptions(
                    backgroundColor: Colors.transparent,
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c']),
                PopupMarkerLayerOptions(
                  markers: getMarkers(),
                  popupSnap: PopupSnap.markerTop,
                  popupController: _popupLayerController,
                  popupBuilder: (BuildContext context, Marker marker) {
                    for (Person person in people) {
                      if (person.location == marker.point) {
                        selectedPerson = person;
                        Timer(Duration(milliseconds: 100), () => setState(() {}));
                        return MarkerPopup(person);
                      }
                    }
                    return Container();
                  },
                ),
              ],
            ),

            //UI
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    //Bottom Buttons
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FloatingActionButton(
                              backgroundColor: Colors.orange,
                              child: Icon(Icons.all_out),
                              onPressed: () {
                                mapController.move(sharedCenter, sharedZoom);
                              },
                            ),
                            SizedBox(
                              width: 0,
                              height: 15,
                            ),
                            FloatingActionButton(
                              backgroundColor: getMarkerColor(selectedPerson),
                              child: Icon(Icons.my_location),
                              onPressed: () {
                                if (selectedPerson == null) {
                                  mapController.move(currentLocation, 15);
                                } else {
                                  mapController.move(selectedPerson.location, 15);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    //Top Buttons/ Settings
                    Align(
                      alignment: Alignment.topRight,
                      child: SettingsPanel(
                        controller: settingsController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
