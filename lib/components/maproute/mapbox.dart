import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapBox extends StatefulWidget {
  final String mapType;
  final LatLng riderLocation;
  final LatLng senderLocation;
  final LatLng receiverLocation;
  final LatLng focusMapCenter;
  final double distance;
  final int orderStatus;
  final List<LatLng> routePoints;
  final String noteHint;
  const MapBox(
      {super.key,
      this.mapType = "rider",
      required this.riderLocation,
      required this.senderLocation,
      required this.receiverLocation,
      required this.distance,
      required this.orderStatus,
      required this.focusMapCenter,
      required this.routePoints,
      required this.noteHint});

  @override
  State<MapBox> createState() => _MapBoxState();
}

class _MapBoxState extends State<MapBox> {
  late MapController _mapController;
  late MapOptions _options;
  Timer? _focusUpdateTimer;
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _options = MapOptions(
      center: widget.focusMapCenter,
      zoom: 16,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusUpdate();
    });
  }

  void zoomIn() {
    final currentZoom = _mapController.zoom;
    final newZoom = currentZoom + 0.2;
    _mapController.move(_mapController.center, newZoom);
  }

  void zoomOut() {
    final currentZoom = _mapController.zoom;
    final newZoom = currentZoom - 0.2;
    _mapController.move(_mapController.center, newZoom);
  }

  void focusUpdate() {
    _focusUpdateTimer?.cancel();
    _focusUpdateTimer = Timer(const Duration(seconds: 10), () {
      debugPrint("Focus Update");
      setState(() {
        if (widget.mapType == "rider") {
          _mapController.move(widget.riderLocation, 16);
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusUpdateTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: _options,
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: widget.routePoints,
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: widget.senderLocation,
                            builder: (ctx) => const Column(
                              children: [
                                Icon(Icons.location_on, color: Colors.red),
                                Text('ผู้ส่ง', style: TextStyle(fontSize: 10))
                              ],
                            ),
                          ),
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: widget.receiverLocation,
                            builder: (ctx) => const Column(
                              children: [
                                Icon(Icons.location_on, color: Colors.orange),
                                Text('ผู้รับ', style: TextStyle(fontSize: 10))
                              ],
                            ),
                          ),
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: widget.riderLocation,
                            builder: (ctx) => Image.asset(
                              'assets/images/rider.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'uniqueTag1',
                          mini: true,
                          onPressed: zoomIn,
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton(
                          heroTag: 'uniqueTag2',
                          mini: true,
                          onPressed: zoomOut,
                          child: const Icon(Icons.remove),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.motorcycle, color: Colors.blue),
                const SizedBox(width: 10),
                Text('Distance: ${widget.distance.toStringAsFixed(2)} km',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue))
              ])),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(widget.noteHint),
            ),
          )
        ],
      ),
    );
  }
}
