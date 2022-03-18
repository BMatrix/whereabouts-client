import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:latlong/latlong.dart';
import 'package:whereabouts_client/models/people.dart';
import 'package:whereabouts_client/models/request.dart';
import 'package:whereabouts_client/models/update.dart';
import 'package:whereabouts_client/services/preferences.dart';

class Location {

  static testConnection() async {
    Socket socket = await Socket.connect(Preferences.preferenceValues["serverIp"], Preferences.preferenceValues["serverPort"]);

    socket.add(utf8.encode('ping'));
    print('ping');

    socket.listen((List<int> event) {
      print(utf8.decode(event));
    });

    socket.close();
  }

  static Future<List<Person>> getSharedLocations() async {
    Socket socket = await Socket.connect(Preferences.preferenceValues["serverIp"], Preferences.preferenceValues["serverPort"]);

    String request = requestToJson(new Request(id: "id goes here"));
    
    socket.add(utf8.encode(request));
    
    People response;
    socket.listen((List<int> event) {
      response = peopleFromJson(utf8.decode(event));
    });
    
    await Future.delayed(Duration(seconds: 1));

    socket.close();
    return response.people;
  }

  static updatePosition(LatLng location) async {
    Socket socket = await Socket.connect(Preferences.preferenceValues["serverIp"], Preferences.preferenceValues["serverPort"]);

    String update = updateToJson(new Update(id: "id goes here", lat: location.latitude, lon: location.longitude, time: DateTime.now()));
    
    socket.add(utf8.encode(update));

    socket.close();
  }
}
