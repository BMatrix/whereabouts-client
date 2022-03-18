/*
{
  "people": [
    {
        "id": "87f9d26c-4101-4b2b-843f-920beaf48e20",
        "lat": 55.555555,
        "lon": 44.444444,
        "time": "2022-03-17T19:54:55"
    },
    {
        "id": "87f9d26c-4101-4b2b-843f-920beaf48e20",
        "lat": 55.555555,
        "lon": 44.444444,
        "time": "2022-03-17T19:54:55"
    },
    {
        "id": "87f9d26c-4101-4b2b-843f-920beaf48e20",
        "lat": 55.555555,
        "lon": 44.444444,
        "time": "2022-03-17T19:54:55"
    }
  ]
}
*/

// Quicktype.io
// To parse this JSON data, do
//
//     final receive = receiveFromJson(jsonString);

// To parse this JSON data, do
//
//     final people = peopleFromJson(jsonString);

import 'dart:convert';

import 'package:latlong/latlong.dart';

People peopleFromJson(String str) => People.fromJson(json.decode(str));

String peopleToJson(People data) => json.encode(data.toJson());

class People {
  People({
    this.people,
  });

  List<Person> people;

  factory People.fromJson(Map<String, dynamic> json) => People(
    people: List<Person>.from(json["people"].map((x) => Person.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "people": List<dynamic>.from(people.map((x) => x.toJson())),
  };

  @override
  String toString() {
    var p = "";
    people.forEach((e) {
      p += e.toString() + "\n";
    });
    return p;
  }
}

class Person {
  Person({
    this.id,
    this.name,
    this.location,
    this.time,
  });

  String id;
  String name;
  LatLng location;
  DateTime time;

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json["id"],
    name: json["id"],
    location: LatLng(json["lat"].toDouble(), json["lon"].toDouble()),
    time: DateTime.parse(json["time"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lat": location.latitude,
    "lon": location.longitude,
    "time": time.toIso8601String(),
  };

  @override
  String toString() {
    return "Id: $id, Name: $name, Location: ${location.toString()}, Time: ${time.toString()}";
  }
}
