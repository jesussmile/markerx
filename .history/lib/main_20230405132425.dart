import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:markerx/markerX.dart';
import 'package:markerx/provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MarkerProvider()),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const MyHomePage(title: 'MarkerX'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<MarkerX> wayPointsMarkersX = [];
  List<Marker> wayPointsMarkers = [];
  double? zoomLevel = 9;
  LatLngBounds latlngBounds = LatLngBounds(LatLng(0, 0), LatLng(0, 0));
  bool showMarkers = false;
  bool showMarkersX = true;
  double doubleInRange(Random source, num start, num end) =>
      source.nextDouble() * (end - start) + start;
  void reset() {
    setState(() {
      showMarkers = false;
      showMarkersX = false;
    });
  }

  void toggleShowMarkers() {
    setState(() {
      showMarkers = true;
      showMarkersX = false;
    });
  }

  void toggleShowMarkerX() {
    setState(() {
      showMarkers = false;
      showMarkersX = true;
    });
  }

  @override
  void initState() {
    loadWayPointsMarkers();
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
    final List<MarkerX> wayPointRouteX =
        _createMarkerXList(jsonData, markerWidth, markerHeight);
    final List<Marker> wayPointsRoute =
        _createMarkerList(jsonData, markerWidth, markerHeight);
    setState(() {
      wayPointsMarkersX = wayPointRouteX;
      wayPointsMarkers = wayPointsRoute;
    });
  }

  List<MarkerX> _createMarkerXList(
      List jsonData, double markerWidth, double markerHeight) {
    return jsonData.map((data) {
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
  }

  List<Marker> _createMarkerList(
      List jsonData, double markerWidth, double markerHeight) {
    return jsonData.map((data) {
      final double latitude = data['latitude'];
      final double longitude = data['longitude'];
      return Marker(
          point: LatLng(latitude, longitude),
          width: markerWidth,
          height: markerHeight,
          builder: (BuildContext context) {
            return const Icon(
              Icons.star,
              color: Colors.purple,
              size: 15,
            );
          });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(child: Text(widget.title)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: reset,
                  child: Text('Click and Drag map to reset '),
                ),
                ElevatedButton(
                  onPressed: toggleShowMarkers,
                  child: const Text('Show Original markers '),
                ),
                ElevatedButton(
                  onPressed: toggleShowMarkerX,
                  child: const Text('Click and Drag map to Show markers X'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(27.7000, 84.3333),
                zoom: 5,
                minZoom: 3,
                onPositionChanged: ((position, hasGesture) {
                  zoomLevel = position.zoom;
                  latlngBounds = position.bounds!;
                  Provider.of<MarkerProvider>(context, listen: false)
                      .setZoom(zoomLevel!, latlngBounds);
                }),
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
                  markers: showMarkersX ? wayPointsMarkersX : [],
                ),
                MarkerLayer(markers: showMarkers ? wayPointsMarkers : []),
              ],
            ),
          )
        ],
      ),
    );
  }
}
