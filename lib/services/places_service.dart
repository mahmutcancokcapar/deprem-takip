import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/place_model.dart';

class PlacesService {
  final String _apiKey = 'AIzaSyCjgON8c5eMmnRGK_X7DeStYqumwSwfn7M';

  Future<List<Place>> getNearbyPlaces(Position position) async {
    final types = ['hospital', 'police', 'fire_station', 'pharmacy', 'park'];
    List<Place> allPlaces = [];

    for (var type in types) {
      final url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=5000&type=$type&key=$_apiKey';
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        for (var item in data['results']) {
          final place = Place.fromJson(item, type, position);
          allPlaces.add(place);
        }
      }
    }

    return allPlaces;
  }
}
