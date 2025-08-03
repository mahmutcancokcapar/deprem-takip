import 'package:geolocator/geolocator.dart';

class Place {
  final String name;
  final String type;
  final String? phoneNumber;
  final double distance;
  final double latitude;
  final double longitude;

  Place({
    required this.name,
    required this.type,
    required this.distance,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
  });

  factory Place.fromJson(
    Map<String, dynamic> json,
    String type,
    Position userPosition,
  ) {
    final placeLocation = json['geometry']['location'];
    final lat = placeLocation['lat'].toDouble();
    final lng = placeLocation['lng'].toDouble();
    final distance = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      lat,
      lng,
    );

    return Place(
      name: json['name'],
      type: type,
      distance: distance / 1000, // km cinsinden
      latitude: lat,
      longitude: lng,
      phoneNumber: json['formatted_phone_number'] ?? "Numara yok",
    );
  }
}
