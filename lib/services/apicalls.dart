// This contain functions for api calls

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ApiCall {
  Future<Position> getCurrentLocation() async {
    // ignore: unused_local_variable
    var status = await Permission.location.status;

    PermissionStatus permission = await Permission.location.request();
    if (permission != PermissionStatus.granted) {
      debugPrint("Permission not granted");
      throw Exception('Location permission not granted');
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );
    return position;
  }
}
