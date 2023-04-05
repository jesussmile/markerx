import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

class MarkerProvider extends ChangeNotifier {
  double mapZoom = 7;
  late LatLngBounds? latLngB;
  void setZoom(double zoom, LatLngBounds? latLngBounds) {
    mapZoom = zoom;
    latLngB = latLngBounds;
    //print("provider $mapZoom");
    //wayPointMarkers = [];
    notifyListeners();
  }
}
