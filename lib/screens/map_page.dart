import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:whereabouts_client/components/settings.dart';
import 'package:whereabouts_client/services/mock_location.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapController mapController = MapController();
  LatLng currentLocation;
  List<Person> people = [];
  Timer timer;
  Timer sharedTimer;

  @override
  void initState() {
    super.initState();
    updatePosition();
    MockLocation.getSharedLocations().then((people) {
      setState(() {
        this.people = people;
      });
    });
    timer = Timer.periodic(Duration(seconds: 10), (t) => updatePosition());
    sharedTimer =
        Timer.periodic(Duration(seconds: 20), (t) => updateSharedPositions());
  }

  @override
  void dispose() {
    timer.cancel();
    sharedTimer.cancel();
    super.dispose();
  }

  void updatePosition() {
    Geolocator.getCurrentPosition().then((position) {
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  void updateSharedPositions() {
    MockLocation.getSharedLocations().then((people) {
      setState(() {
        this.people = people;
      });
    });
  }

  LatLng getLatLng() {
    return LatLng(currentLocation.latitude, currentLocation.longitude);
  }

  List<Marker> getMarkers() {
    List<Marker> markers = [];
    if (currentLocation != null) {
      markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
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

    for (Person person in people) {
      markers.add(
        Marker(
          point: person.location,
          builder: (ctx) => Container(
            child: Icon(
              Icons.person_pin,
              color: Colors.green,
              size: 50,
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
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: LatLng(0, 0),
              zoom: 2.0,
            ),
            layers: [
              TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']),
              MarkerLayerOptions(
                markers: getMarkers(),
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Settings(),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FloatingActionButton(
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.all_out),
                            onPressed: () {},
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
