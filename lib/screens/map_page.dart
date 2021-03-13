import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:whereabouts_client/components/settings.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapController mapController = MapController();
  Position currentLocation;
  Timer timer;

  @override
  void initState() {
    super.initState();
    Geolocator.getCurrentPosition().then((value) {
      setState(() {
        currentLocation = value;
        mapController.move(getLatLng(), 15);
      });
    });
    timer = Timer.periodic(Duration(seconds: 10), (t) => getPosition());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void getPosition() {
    Geolocator.getCurrentPosition().then((value) {
      setState(() {
        currentLocation = value;
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
          point: getLatLng(),
          builder: (ctx) => Container(
            child: Icon(
              Icons.radio_button_checked,
              color: Colors.blue,
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
                              mapController.move(getLatLng(), 15);
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
