import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> isPermissionGranted() async {
    return await Geolocator.checkPermission() == LocationPermission.always ||
        await Geolocator.checkPermission() == LocationPermission.whileInUse;
  }

  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<Position> getCurrentPosition() async {
    // ignore: deprecated_member_use
    return await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
