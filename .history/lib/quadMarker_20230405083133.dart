import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:markerx/markerX.dart';

class MarkerQuadtree {
  late final LatLngBounds bounds;
  late final int capacity;
  final List<MarkerX> markers = [];
  final List<MarkerQuadtree> subTrees =
      []; // <-- Initialize subTrees in the constructor
  bool divided = false;
  MarkerQuadtree(this.bounds, this.capacity);
  void insert(MarkerX marker) {
    if (!bounds.contains(marker.point)) {
      return; // marker is outside the bounds of this tree, ignore it
    }
    if (markers.length < capacity) {
      markers.add(marker);
      return;
    }
    if (!divided) {
      _subdivide();
    }
    for (final subTree in subTrees) {
      subTree.insert(marker);
    }
  }

  List<MarkerX> query(LatLngBounds searchBounds) {
    final result = <MarkerX>[];
    if (!bounds.containsBounds(searchBounds)) {
      return result; // this tree doesn't intersect the search bounds, return empty list
    }
    for (final marker in markers) {
      if (searchBounds.contains(marker.point)) {
        result.add(marker);
      }
    }
    if (divided) {
      for (final subTree in subTrees) {
        result.addAll(subTree.query(searchBounds));
      }
    }
    return result;
  }

  void _subdivide() {
    final xMid = bounds.center.latitude;
    final yMid = bounds.center.longitude;
    final northWest = LatLngBounds(
      LatLng(bounds.north, bounds.west),
      LatLng(xMid, yMid),
    );
    final northEast = LatLngBounds(
      LatLng(bounds.north, yMid),
      LatLng(xMid, bounds.east),
    );
    final southWest = LatLngBounds(
      LatLng(xMid, bounds.west),
      LatLng(bounds.south, yMid),
    );
    final southEast = LatLngBounds(
      LatLng(xMid, yMid),
      LatLng(bounds.south, bounds.east),
    );
    subTrees.addAll([
      MarkerQuadtree(northWest, capacity),
      MarkerQuadtree(northEast, capacity),
      MarkerQuadtree(southWest, capacity),
      MarkerQuadtree(southEast, capacity),
    ]);
    divided = true;
  }
}
