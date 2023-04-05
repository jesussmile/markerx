import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:markerx/markerX.dart';
import 'package:markerx/test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MarkerX'),
    );
  }
}

const maxMarkersCount = 1000;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<MarkerX> wayPointsMarkers = [];
  List<MarkerZ> wayPointsMarkersZ = [];
  bool showMarkers = true;

  double doubleInRange(Random source, num start, num end) =>
      source.nextDouble() * (end - start) + start;
  void toggleShowMarkers() {
    setState(() {
      showMarkers = !showMarkers;
    });
  }

  @override
  void initState() {
    loadWayPointsMarkers();
    loadWayPointsMarkersZ();
    super.initState();
  }

  Future<void> loadWayPointsMarkers() async {
    double markerWidth = 5;
    double markerHeight = 5;
    // Load the JSON file containing the markers
    final String jsonString =
        await rootBundle.loadString('assets/Waypoints.json');
    // Decode the JSON data into a List of Maps
    final List<dynamic> jsonData = await json.decode(jsonString);
    // Create a List of Markers from the JSON data
    List<MarkerX> wayPointRouteM = jsonData.map((data) {
      final double latitude = data['latitude'];
      final double longitude = data['longitude'];

      const width = 3.0, height = 3.0;
      final paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 2;
      return MarkerX(
          point: LatLng(latitude, longitude),
          onDraw: (canvas, offset) {
            canvas.drawCircle(offset + const Offset(0, height), 2, paint);
          },
          width: markerWidth,
          height: markerHeight);
    }).toList();
    print(wayPointRouteM.length);

    setState(() {
      wayPointsMarkers = wayPointRouteM;
    });
  }

  Future<void> loadWayPointsMarkersZ() async {
    double markerWidth = 5;
    double markerHeight = 5;
    // Load the JSON file containing the markers
    final String jsonString =
        await rootBundle.loadString('assets/Waypoints.json');
    // Decode the JSON data into a List of Maps
    final List<dynamic> jsonData = await json.decode(jsonString);
    // Create a List of Markers from the JSON data
    List<MarkerZ> wayPointRouteM = jsonData.map((data) {
      final double latitude = data['latitude'];
      final double longitude = data['longitude'];

      const width = 3.0, height = 3.0;
      final paint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2;
      return MarkerZ(
          point: LatLng(latitude, longitude),
          onDraw: (canvas, offset) {
            canvas.drawCircle(offset + const Offset(0, height), 2, paint);
          },
          width: markerWidth,
          height: markerHeight);
    }).toList();
    print(wayPointRouteM.length);

    setState(() {
      wayPointsMarkersZ = wayPointRouteM;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(child: Text(widget.title)),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: toggleShowMarkers,
            child: Text('Show markers x'),
          ),
          ElevatedButton(
            onPressed: toggleShowMarkers,
            child: Text('Show markers z'),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(27.7000, 84.3333),
                zoom: 7,
                minZoom: 6,
                interactiveFlags:
                    InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayerX(
                  // markers: [],
                  markers: showMarkers ? wayPointsMarkers : [],
                ),
                MarkerLayerZ(
                  markers: showMarkers ? wayPointsMarkersZ : [],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
