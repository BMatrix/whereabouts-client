import 'dart:math';

import 'package:latlong/latlong.dart';

class Person {
  Person(String name, LatLng location, DateTime time) {
    this.name = name;
    this.location = location;
    this.time = time;
  }

  String name;
  LatLng location;
  DateTime time;
}

Random random = Random();
List<String> mocknames = ["A", "B", "C", "D", "E"];

class MockLocation {
  //Simulates requesting locations from the server
  //There is a 1 second delay untill locations are returned
  static Future<List<Person>> getSharedLocations() {
    return Future.delayed(Duration(seconds: 1), () {
      List<Person> people = [];
      for (int i = 0; i < 2; i++) {
        Person person = Person(
          mocknames[i],
          LatLng((random.nextDouble() * 115) - 35,
              (random.nextDouble() * 360) - 180),
          DateTime.now(),
        );
        people.add(person);
      }
      return people;
    });
  }
}
