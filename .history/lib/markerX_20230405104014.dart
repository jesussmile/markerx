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
  int visibilityCount; // Add visibilityCount property

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
  })  : anchor = Anchor.forPos(anchorPos, width, height),
        visibilityCount = 0; // initialize visibilityCount to 0

  void incrementVisibilityCount() {
    // Add incrementVisibilityCount method
    visibilityCount++;
  }

  void decrementVisibilityCount() {
    visibilityCount--;
  }
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
  @override
  void initState() {
    super.initState();
    final markers = widget.markers;
    final bounds = Provider.of<MarkerProvider>(context, listen: false).latLngB!;
    markerQuadtree = MarkerQuadtree(bounds, 4); // adjust capacity as needed

    _putMarkers(bounds, markers).then((_) {
      visibleMarkers = _getVisibleMarkers();
    });
    // visibleMarkers = _getVisibleMarkers();
  }

  Future<void> _putMarkers(LatLngBounds bounds, List<MarkerX> markers) async {
    for (final marker in markers) {
      markerQuadtree.insert(marker);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    map = FlutterMapState.maybeOf(context)!;
    visibleMarkers = _getVisibleMarkers();
  }

  List<MarkerX> _getVisibleMarkers() {
    final visibleMarkers = markerQuadtree.query(map.bounds);
    for (var marker in visibleMarkers) {
      marker.incrementVisibilityCount();
    } // Call incrementVisibilityCount method on each visible marker
    return visibleMarkers;
  }

  @override
  Widget build(BuildContext context) {
    final newBound =
        Provider.of<MarkerProvider>(context, listen: false).latLngB;
    if (newBound != markerQuadtree.bounds) {
      markerQuadtree =
          MarkerQuadtree(newBound!, 5000); // adjust capacity as needed
      for (final marker in widget.markers) {
        markerQuadtree.insert(marker);
      }
    }
    visibleMarkers = _getVisibleMarkers();
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
              )))
          : RepaintBoundary(
              child: CustomPaint(
              painter: _MarkerPainter(marker.onDraw),
            ));
      final markerWidgetWithStream = marker.stream == null
          ? markerWidget
          : StreamBuilder<dynamic>(
              stream: marker.stream,
              builder: (context, snapshot) {
                return markerWidget;
              });
      return Positioned(
        key: marker.key,
        width: marker.width,
        height: marker.height,
        left: pos.x - rightPortion,
        top: pos.y - bottomPortion,
        child: markerWidgetWithStream,
      );
    }).toList();
    return Stack(
      children: markerWidgets,
    );
  }
}

class _MarkerPainter extends CustomPainter {
  final void Function(Canvas canvas, Offset offset) onDraw;
  _MarkerPainter(this.onDraw);
  @override
  void paint(Canvas canvas, Size size) => onDraw(canvas, Offset.zero);
  @override
  bool shouldRepaint(_MarkerPainter oldDelegate) => false;
}
