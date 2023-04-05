import 'package:flutter/material.dart';

class MarkerProvider extends ChangeNotifier {
  double mapZoom = 7;
  void setZoom(double zoom) {
    mapZoom = zoom;
    //print("provider $mapZoom");
    //wayPointMarkers = [];
    notifyListeners();
  }
}
