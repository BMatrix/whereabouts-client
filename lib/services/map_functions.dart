import 'dart:math';

import 'package:latlong/latlong.dart';
import 'package:whereabouts_client/services/mock_location.dart';

//Used to prevent List<double> minMax = [-90,90,-180,180] which provides no decent context in how it is used
class _LatLngMinMax {
  double maxLat = -90, minLat = 90, maxLng = -180, minLng = 180;
}

class MapFunctions {
  //ToDo: Use this at some point. I should compensate the fact that on the Mercator map projections land area is way larger near the poles
  //It's not nessecary at all unless some people are on the North Pole and Antartica at the same time
  double mercatorDeviationCorrection(double lat) {
    return log(tan((pi / 4) + (lat / 2)));
  }

  //Extracts locations from Person lists
  static List<LatLng> peopleToLatLngs(List<Person> people) {
    List<LatLng> positions = [];
    for (Person person in people) {
      positions.add(person.location);
    }
    return positions;
  }

  //Get largest/ smallest lattitude/ longitudes from all coordinates
  static _LatLngMinMax _getMinMax(List<LatLng> locations) {
    _LatLngMinMax minMax = _LatLngMinMax();
    for (LatLng location in locations) {
      if (location.latitude > minMax.maxLat) {
        minMax.maxLat = location.latitude;
      }
      if (location.latitude < minMax.minLat) {
        minMax.minLat = location.latitude;
      }
      if (location.longitude > minMax.maxLng) {
        minMax.maxLng = location.longitude;
      }
      if (location.longitude < minMax.minLng) {
        minMax.minLng = location.longitude;
      }
    }
    return minMax;
  }

  //Calculates overall center from all locations
  static LatLng getSharedCenter(List<LatLng> locations) {
    _LatLngMinMax minMax = _getMinMax(locations);

    return LatLng((minMax.minLat + minMax.maxLat) / 2, (minMax.minLng + minMax.maxLng) / 2);
  }

  //Calculates appropriate zoom level to fit all coordinates on screen at once
  //Zoom level details: https://wiki.openstreetmap.org/wiki/Zoom_levels
  static double getSharedZoom(List<LatLng> locations) {
    _LatLngMinMax minMax = _getMinMax(locations);
    List<double> sharedCenterBoundingBox = [minMax.maxLat - minMax.minLat, minMax.maxLng - minMax.minLng];

    //Determines if latitude or longitude should be used to fit on the screen
    //If the bounding box of _LatLngMinMax has an aspect ratio larger then 16/9 use longitude instead of latitude
    int useLng = 1;
    if (sharedCenterBoundingBox[0] / sharedCenterBoundingBox[1] > 16 / 9) {
      useLng = 0;
    }

    double angle = 360;
    for (int i = 0; i < 20; i++) {
      if (sharedCenterBoundingBox[useLng] > angle) {
        return (i - 1).toDouble();
      } else {
        angle /= 2;
      }
    }

    return 0;
  }
}
