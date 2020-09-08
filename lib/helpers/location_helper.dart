import 'dart:convert';

import 'package:http/http.dart' as http;

const GOOGLE_API_KEY = "AIzaSyDiM5_zcRTckRdPg96QvaCPbIrg7b2ug0Q";

class LocationHelper {
  static String generateLocationPreviewImage(
      {double latitude, double longitude}) {
    return "https://maps.googleapis.com/maps/api/staticmap?center=25.3822499,68.3241407&zoom=1&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$GOOGLE_API_KEY";
  }

  static Future<String> getPlaceAddress(double latitude, double longitude) {
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$GOOGLE_API_KEY";
    return http.get(url).then((response) {
      print(json.decode(response.body));
      return Future.value(
          json.decode(response.body)['results'][0]['formatted_address']);
    });
  }
}
