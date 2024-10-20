import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapBox extends StatefulWidget {
  const MapBox({super.key});

  @override
  State<MapBox> createState() => _MapBoxState();
}

class _MapBoxState extends State<MapBox> {
  final MapOptions _options = MapOptions(
    center: const LatLng(16.2465759, 103.2123492),
    zoom: 12,
  );

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
              child: FlutterMap(
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
                        points: [],
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
                        point: const LatLng(16.2465759, 103.2123492),
                        builder: (ctx) =>
                            const Icon(Icons.location_on, color: Colors.red),
                      ),
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: const LatLng(16.2465759, 103.2123492),
                        builder: (ctx) =>
                            const Icon(Icons.location_on, color: Colors.blue),
                      ),
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: const LatLng(16.2485759, 103.2203892),
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
            ),
          )
        ],
      ),
    );
  }
}
