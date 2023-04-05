import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

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

class MarkerLayerX extends StatelessWidget {
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

  List<MarkerX> _getVisibleMarkers(FlutterMapState map) {
    final visibleMarkers = <MarkerX>[];
    final pixelOrigin = map.pixelOrigin;

    for (final marker in markers) {
      final pxPoint = map.project(marker.point);
      final rightPortion = marker.width - marker.anchor.left;
      final leftPortion = marker.anchor.left;
      final bottomPortion = marker.height - marker.anchor.top;
      final topPortion = marker.anchor.top;

      final pos = pxPoint - pixelOrigin;
      final markerBounds = Bounds(
        CustomPoint(pxPoint.x + leftPortion, pxPoint.y - bottomPortion),
        CustomPoint(pxPoint.x - rightPortion, pxPoint.y + topPortion),
      );

      if (!map.pixelBounds.containsPartialBounds(markerBounds)) {
        continue; // marker is not within visible area, skip it
      }

      visibleMarkers.add(marker);
    }

    return visibleMarkers;
  }

  @override
  Widget build(BuildContext context) {
    final map = FlutterMapState.maybeOf(context)!;

    // print('build method called');
    final visibleMarkers = _getVisibleMarkers(map);
    final markerWidgets = visibleMarkers.map((marker) {
      final pxPoint = map.project(marker.point);
      final rightPortion = marker.width - marker.anchor.left;
      final leftPortion = marker.anchor.left;
      final bottomPortion = marker.height - marker.anchor.top;
      final topPortion = marker.anchor.top;
      final pos = pxPoint - map.pixelOrigin;
      final markerWidget = (marker.rotate ?? rotate)
          ? Transform.rotate(
              angle: -map.rotationRad,
              origin: marker.rotateOrigin ?? rotateOrigin,
              alignment: marker.rotateAlignment ?? rotateAlignment,
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
      final markerWidgetWithStream = marker.stream == null
          ? markerWidget
          : StreamBuilder<dynamic>(
              stream: marker.stream,
              builder: (context, snapshot) {
                return markerWidget;
              },
            );
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
  void paint(Canvas canvas, Size size) {
    onDraw(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(_MarkerPainter oldDelegate) {
    return false;
  }
}
