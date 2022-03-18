import 'dart:math';

import 'package:latlong/latlong.dart';
import 'package:whereabouts_client/models/people.dart';

Random random = Random();
List<String> mocknames = ["Aaaaa", "Bbbbb", "Ccccc", "Ddddd", "Eeeee"];

class MockLocation {
  //Simulates requesting locations from the server
  //There is a 1 second delay untill locations are returned
  static Future<List<Person>> getSharedLocations() {
    return Future.delayed(Duration(seconds: 1), () {
      List<Person> people = [];
      for (int i = 0; i < 2; i++) {
        Person person = new Person(
          id: Random.secure().nextInt(99999).toString(),
          name: mocknames[i],
          location: LatLng((random.nextDouble() * 115) - 35, (random.nextDouble() * 360) - 180),
          time: DateTime.now()
        );
        people.add(person);
      }
      return people;
    });
  }
}
