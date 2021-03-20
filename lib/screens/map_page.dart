import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
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
  LatLng currentLocation;
  LatLng sharedCenter; //Center point of all shared locations and your own position
  bool sharedCenterEnable = false; //Enables visual sharedCenter on the map
  double sharedZoom; //Zoom level to use with the "center all" button
  List<Person> people = [];
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

  //Get shared List<Person>, store them, set vars, move to overview of all locations
  void updateShared({bool move: false}) {
    MockLocation.getSharedLocations().then((people) {
      setState(() {
        this.people = people;
        List<LatLng> locations = MapFunctions.peopleToLatLngs(people);
        if (currentLocation != null) {
          locations.add(currentLocation);
        }
        sharedCenter = MapFunctions.getSharedCenter(locations);
        sharedZoom = MapFunctions.getSharedZoom(locations);
        if (move) {
          mapController.move(sharedCenter, sharedZoom);
        }
      });
    });
  }

  List<Marker> getMarkers() {
    List<Marker> markers = [];

    //Current position
    if (currentLocation != null) {
      markers.add(
        Marker(
          point: currentLocation,
          builder: (ctx) => Container(
            child: Icon(
              Icons.radio_button_checked,
              color: Colors.blue,
            ),
          ),
        ),
      );
    }

    //All shared locations
    for (Person person in people) {
      markers.add(
        Marker(
          point: person.location,
          height: 85,
          width: 50,
          builder: (ctx) => Container(
            child: Column(
              children: [
                Icon(
                  Icons.person_pin,
                  color: Colors.green,
                  size: 50,
                ),
                SizedBox(
                  height: 35,
                  width: 50,
                )
              ],
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

  Widget build(BuildContext context) {
    return Container(
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
            ),
            layers: [
              TileLayerOptions(
                  backgroundColor: Colors.transparent,
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']),
              MarkerLayerOptions(
                markers: getMarkers(),
              ),
            ],
          ),

          //UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    //Top Buttons/ Settings
                    Expanded(
                      flex: 3,
                      child: Settings(),
                    ),

                    //Bottom Buttons
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FloatingActionButton(
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.all_out),
                            onPressed: () {
                              mapController.move(sharedCenter, sharedZoom);
                              mapController.rotate(0);
                            },
                          ),
                          SizedBox(
                            width: 0,
                            height: 15,
                          ),
                          FloatingActionButton(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.my_location),
                            onPressed: () {
                              mapController.move(currentLocation, 15);
                              mapController.rotate(0);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
