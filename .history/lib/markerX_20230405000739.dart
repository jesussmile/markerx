import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:markerx/provider.dart';
import 'package:provider/provider.dart';

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
  // double currentZoom = 0;
  //late LatLngBounds? currentBound;
  LatLngBounds currentBound = LatLngBounds(LatLng(0, 0), LatLng(0, 0));

  List<MarkerX> visibleMarkers = [];
  // Define a cache for computed results
  final _markerCache = <LatLngBounds, List<MarkerX>>{};

  @override
  void initState() {
    super.initState();

    // currentZoom = Provider.of<MarkerProvider>(context, listen: false).mapZoom;
    currentBound = Provider.of<MarkerProvider>(context, listen: false).latLngB!;
    // visibleMarkers = _getVisibleMarkers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    map = FlutterMapState.maybeOf(context)!;
  }

  List<MarkerX> _getVisibleMarkers() {
    final cachedMarkers = _markerCache[currentBound];
    if (cachedMarkers != null) {
      return cachedMarkers;
    }
    final visibleMarkers = <MarkerX>[];

    for (final marker in widget.markers) {
      final pxPoint = map.project(marker.point);
      final rightPortion = marker.width - marker.anchor.left;
      final leftPortion = marker.anchor.left;
      final bottomPortion = marker.height - marker.anchor.top;
      final topPortion = marker.anchor.top;
      final sw =
          CustomPoint(pxPoint.x + leftPortion, pxPoint.y - bottomPortion);
      final ne = CustomPoint(pxPoint.x - rightPortion, pxPoint.y + topPortion);
      if (!map.pixelBounds.containsPartialBounds(Bounds(sw, ne))) {
        continue; // marker is not within visible area, skip it
      }
      visibleMarkers.add(marker);
    }
    _markerCache[currentBound] = visibleMarkers;
    return visibleMarkers;
  }

  @override
  Widget build(BuildContext context) {
    // final newZoom = Provider.of<MarkerProvider>(context).mapZoom;
    final newBound =
        Provider.of<MarkerProvider>(context, listen: false).latLngB;
    print(
        'newZOOM ${newBound!.southWest} currentZoom ${currentBound.northEast}');
    if (newBound != currentBound) {
      print('inside _getvisiblemarkers');
      currentBound = newBound!;
      visibleMarkers = _getVisibleMarkers();
      _markerCache.remove(currentBound);
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