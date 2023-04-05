import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:markerx/provider.dart';
import 'package:markerx/quadMarker.dart';
import 'package:provider/provider.dart';

//import 'package:quadtree_dart/quadtree_dart.dart';
class MarkerX {
  final LatLng point;
  final Key? key;
  final double width;
  final double height;
  final Anchor anchor;
  final bool? rotate;
  final Offset? rotateOrigin;
  final AlignmentGeometry? rotateAlignment;
  final void Function(Canvas canvas, Offset offset) onDraw;
  final Stream<dynamic>? stream;
  MarkerX({
    required this.point,
    this.key,
    this.width = 30.0,
    this.height = 30.0,
    this.rotate,
    this.rotateOrigin,
    this.rotateAlignment,
    AnchorPos<dynamic>? anchorPos,
    required this.onDraw,
    this.stream,
  }) : anchor = Anchor.forPos(anchorPos, width, height);
}

class MarkerLayerX extends StatefulWidget {
  final List<MarkerX> markers;
  final bool rotate;
  final Offset? rotateOrigin;
  final AlignmentGeometry? rotateAlignment;
  const MarkerLayerX({
    Key? key,
    this.markers = const [],
    this.rotate = false,
    this.rotateOrigin,
    this.rotateAlignment = Alignment.center,
  }) : super(key: key);
  @override
  State<MarkerLayerX> createState() => _MarkerLayerXState();
}

class _MarkerLayerXState extends State<MarkerLayerX> {
  late FlutterMapState map;
  late MarkerQuadtree markerQuadtree;
  List<MarkerX> visibleMarkers = [];
  final StreamController _markerStreamController = StreamController.broadcast();
  LatLngBounds? _cachedBounds;

  @override
  void initState() {
    super.initState();
    final markers = widget.markers;
    final bounds = Provider.of<MarkerProvider>(context, listen: false).latLngB!;
    markerQuadtree = MarkerQuadtree(bounds, 5000); // adjust capacity as needed
    _putMarkers(bounds, markers);

    _listenToMarkerStream();
  }

  void _listenToMarkerStream() {
    if (widget.markers.any((marker) => marker.stream != null)) {
      _markerStreamController.stream.listen((_) {
        setState(() {});
      });
    }
  }

  void _putMarkers(LatLngBounds bounds, List<MarkerX> markers) {
    for (final marker in markers) {
      markerQuadtree.insert(marker);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    map = FlutterMapState.maybeOf(context)!;
    final newBound =
        Provider.of<MarkerProvider>(context, listen: false).latLngB;
    if (newBound != _cachedBounds) {
      _cachedBounds = newBound;
      markerQuadtree =
          MarkerQuadtree(newBound!, 5000); // adjust capacity as needed
      _putMarkers(newBound!, widget.markers);
      visibleMarkers = _getVisibleMarkers();
    }
  }

  List<MarkerX> _getVisibleMarkers() {
    return markerQuadtree.query(map.bounds);
  }

  @override
  Widget build(BuildContext context) {
    final newBound =
        Provider.of<MarkerProvider>(context, listen: false).latLngB;
    if (newBound != _cachedBounds) {
      _cachedBounds = newBound;
      markerQuadtree =
          MarkerQuadtree(newBound!, 5000); // adjust capacity as needed
      _putMarkers(newBound!, widget.markers);
      visibleMarkers = _getVisibleMarkers();
    }
    final markerWidgets = visibleMarkers.map((marker) {
      final pxPoint = map.project(marker.point);
      final rightPortion = marker.width - marker.anchor.left;
      final leftPortion = marker.anchor.left;
      final bottomPortion = marker.height - marker.anchor.top;
      final topPortion = marker.anchor.top;
      final pos = pxPoint - map.pixelOrigin;
      final markerWidget = (marker.rotate ?? widget.rotate)
          ? Transform.rotate(
              angle: -map.rotationRad,
              origin: marker.rotateOrigin ?? widget.rotateOrigin,
              alignment: marker.rotateAlignment ?? widget.rotateAlignment,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _MarkerPainter(marker.onDraw),
                ),
              ),
            )
          : RepaintBoundary(
              child: CustomPaint(
                painter: _MarkerPainter(marker.onDraw),
              ),
            );
      return Positioned(
        key: marker.key,
        width: marker.width,
        height: marker.height,
        left: pos.x - rightPortion,
        top: pos.y - bottomPortion,
        child: marker.stream == null
            ? markerWidget
            : StreamBuilder(
                stream: _markerStreamController.stream,
                builder: (context, snapshot) {
                  return markerWidget;
                },
              ),
      );
    }).toList();
    return Stack(
      children: markerWidgets,
    );
  }

  @override
  void dispose() {
    _markerStreamController.close();
    super.dispose();
  }
}

class _MarkerPainter extends CustomPainter {
  final void Function(Canvas canvas, Offset offset) onDraw;
  const _MarkerPainter(this.onDraw);
  @override
  void paint(Canvas canvas, Size size) => onDraw(canvas, Offset.zero);
  @override
  bool shouldRepaint(_MarkerPainter oldDelegate) => false;
}
