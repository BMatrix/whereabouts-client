/*
{
    "id": "87f9d26c-4101-4b2b-843f-920beaf48e20"
}
*/

// Quicktype.io
// To parse this JSON data, do
//
//     final request = requestFromJson(jsonString);

import 'dart:convert';

Request requestFromJson(String str) => Request.fromJson(json.decode(str));

String requestToJson(Request data) => json.encode(data.toJson());

class Request {
  Request({
    this.id,
  });

  String id;

  factory Request.fromJson(Map<String, dynamic> json) => Request(
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
  };
}
