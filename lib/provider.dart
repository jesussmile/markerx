import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class MarkerProvider extends ChangeNotifier {
  double mapZoom = 7;
  late LatLngBounds? latLngB = LatLngBounds(LatLng(0, 0), LatLng(0, 0));

  void setZoom(double zoom, LatLngBounds? latLngBounds) {
    mapZoom = zoom;
    latLngB = latLngBounds;
    //print("provider $mapZoom");
    //wayPointMarkers = [];
    notifyListeners();
  }
}
