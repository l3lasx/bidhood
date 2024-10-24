import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:bidhood/components/layouts/user.dart';
import 'dart:async';
import 'dart:math';

class GroupMapPage extends ConsumerStatefulWidget {
  const GroupMapPage({
    super.key,
  });

  @override
  ConsumerState<GroupMapPage> createState() => _GroupMapPageState();
}

class _GroupMapPageState extends ConsumerState<GroupMapPage> {
  late Timer _timer;
  final MapController _mapController = MapController();
  final List<LatLng> _riderPositions = [];
  final List<LatLng> _senderPositions = [];
  final List<LatLng> _receiverPositions = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializePositions();
    _startSimulation();
  }

  void _initializePositions() {
    // Initialize 5 riders, 3 senders, and 3 receivers
    for (int i = 0; i < 5; i++) {
      _riderPositions.add(_randomPosition());
    }
    for (int i = 0; i < 3; i++) {
      _senderPositions.add(_randomPosition());
      _receiverPositions.add(_randomPosition());
    }
  }

  LatLng _randomPosition() {
    // Generate random positions around Bangkok
    double lat = 13.7563 + (_random.nextDouble() - 0.5) * 0.1;
    double lng = 100.5018 + (_random.nextDouble() - 0.5) * 0.1;
    return LatLng(lat, lng);
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _updateRiderPositions();
      });
    });
  }

  void _updateRiderPositions() {
    for (int i = 0; i < _riderPositions.length; i++) {
      double lat =
          _riderPositions[i].latitude + (_random.nextDouble() - 0.5) * 0.001;
      double lng =
          _riderPositions[i].longitude + (_random.nextDouble() - 0.5) * 0.001;
      _riderPositions[i] = LatLng(lat, lng);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UserLayout(
      bodyWidget: Positioned(
        top: 50,
        left: 0,
        right: 0,
        bottom: 0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildMapContainer(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _calculateMapCenter(),
            zoom: 12.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: _buildMarkers(),
            ),
          ],
        ),
      ),
    );
  }

  LatLng _calculateMapCenter() {
    double sumLat = 0, sumLng = 0;
    int totalPoints = _riderPositions.length +
        _senderPositions.length +
        _receiverPositions.length;

    for (var pos in _riderPositions + _senderPositions + _receiverPositions) {
      sumLat += pos.latitude;
      sumLng += pos.longitude;
    }

    return LatLng(sumLat / totalPoints, sumLng / totalPoints);
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    for (var pos in _senderPositions) {
      markers.add(Marker(
        width: 40.0,
        height: 40.0,
        point: pos,
        builder: (ctx) =>
            const Icon(Icons.person_pin_circle, color: Colors.blue, size: 30),
      ));
    }

    for (var pos in _receiverPositions) {
      markers.add(Marker(
        width: 40.0,
        height: 40.0,
        point: pos,
        builder: (ctx) =>
            const Icon(Icons.location_on, color: Colors.red, size: 30),
      ));
    }

    for (var pos in _riderPositions) {
      markers.add(Marker(
        width: 40.0,
        height: 40.0,
        point: pos,
        builder: (ctx) =>
            const Icon(Icons.motorcycle, color: Colors.green, size: 30),
      ));
    }

    return markers;
  }
}
