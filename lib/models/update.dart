// To parse this JSON data, do
//
//     final update = updateFromJson(jsonString);

import 'dart:convert';

Update updateFromJson(String str) => Update.fromJson(json.decode(str));

String updateToJson(Update data) => json.encode(data.toJson());

class Update {
  Update({
    this.id,
    this.lat,
    this.lon,
    this.time,
  });

  String id;
  double lat;
  double lon;
  DateTime time;

  factory Update.fromJson(Map<String, dynamic> json) => Update(
    id: json["id"],
    lat: json["lat"].toDouble(),
    lon: json["lon"].toDouble(),
    time: DateTime.parse(json["time"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lat": lat,
    "lon": lon,
    "time": time.toIso8601String(),
  };
}
