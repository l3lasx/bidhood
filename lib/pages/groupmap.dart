import 'package:bidhood/services/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
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

class MapLocation {
  final LatLng riderPosition;
  final LatLng senderPosition;
  final LatLng receiverPosition;
  final String transactionId;
  final String riderName;
  final String senderName;
  final String receiverName;

  MapLocation({
    required this.riderPosition,
    required this.senderPosition,
    required this.receiverPosition,
    required this.transactionId,
    required this.riderName,
    required this.senderName,
    required this.receiverName,
  });
}

class _GroupMapPageState extends ConsumerState<GroupMapPage> {
  final MapController _mapController = MapController();
  final Map<String, MapLocation> _locationMap = {};
  final FirebaseFirestore db = FirebaseFirestore.instance;
  List<String> transactions = [];
  // ignore: prefer_final_fields
  List<StreamSubscription> _subscriptions = [];
  bool _isLoading = true;
  String? _error;

  double _parseDouble(dynamic value) {
    if (value == null) {
      throw const FormatException('Value is null');
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.parse(value);
    }
    throw FormatException('Unable to parse $value to double');
  }

  @override
  void initState() {
    super.initState();
    _fetchOrderData();
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _mapController.dispose();
    super.dispose();
  }

  void _fetchOrderData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      var result = await ref.read(orderService).getMeSender();
      if (!mounted) return;

      final orders = (result['data']?['data'] as List?)?.where((order) {
            return (order['status'] >= 2 &&
                (order['is_order_complete'] != true));
          }).toList() ??
          [];

      setState(() {
        transactions = orders
            .map<String>((order) => order['order_transaction_id'].toString())
            .toList();
        debugPrint("$transactions");
        _isLoading = false;
      });

      startRealtimeGet();
    } catch (e) {
      setState(() {
        _error = 'Error fetching order data: $e';
        _isLoading = false;
      });
      debugPrint('Error fetching order data: $e');
    }
  }

  void startRealtimeGet() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _locationMap.clear();

    for (var transactionId in transactions) {
      var docRef = db.collection("transactions").doc(transactionId);
      var subscription = docRef.snapshots().listen(
        (snapshot) {
          if (!mounted) return;
          if (snapshot.exists) {
            var data = snapshot.data()!;
            setState(() {
              try {
                final riderLocation =
                    data['rider_location'] as Map<String, dynamic>?;
                final senderLocation =
                    data['sender_location'] as Map<String, dynamic>?;
                final receiverLocation =
                    data['receiver_location'] as Map<String, dynamic>?;

                if (riderLocation == null ||
                    senderLocation == null ||
                    receiverLocation == null) {
                  throw FormatException('Missing location data');
                }

                MapLocation newLocation = MapLocation(
                  riderPosition: LatLng(
                    _parseDouble(riderLocation['Lat']),
                    _parseDouble(riderLocation['Long']),
                  ),
                  senderPosition: LatLng(
                    _parseDouble(senderLocation['Lat']),
                    _parseDouble(senderLocation['Long']),
                  ),
                  receiverPosition: LatLng(
                    _parseDouble(receiverLocation['Lat']),
                    _parseDouble(receiverLocation['Long']),
                  ),
                  transactionId: transactionId,
                  riderName: data['rider_name'] ?? 'Rider',
                  senderName: data['sender_name'] ?? 'Sender',
                  receiverName: data['receiver_name'] ?? 'Receiver',
                );

                _locationMap[transactionId] = newLocation;

                if (_locationMap.isNotEmpty) {
                  _mapController.move(
                      _calculateMapCenter(), _calculateZoomLevel());
                }
              } catch (e) {
                debugPrint('Error processing location data: $e');
                debugPrint('Raw data: ${data.toString()}');
                AlertController.show(
                    "Error", "Failed to update location data", TypeAlert.error);
              }
            });
          }
        },
        onError: (error) {
          debugPrint('Error in transaction listener: $error');
          AlertController.show("Error", "Failed to connect to location service",
              TypeAlert.error);
        },
      );
      _subscriptions.add(subscription);
    }
  }

  void _focusOnRider(String transactionId) {
    if (_locationMap.containsKey(transactionId)) {
      final location = _locationMap[transactionId]!;
      _mapController.move(location.riderPosition, 15.0);
    }
  }

  double _calculateZoomLevel() {
    if (_locationMap.isEmpty) return 12.0;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (var location in _locationMap.values) {
      minLat = min(minLat, location.senderPosition.latitude);
      maxLat = max(maxLat, location.senderPosition.latitude);
      minLng = min(minLng, location.senderPosition.longitude);
      maxLng = max(maxLng, location.senderPosition.longitude);

      minLat = min(minLat, location.receiverPosition.latitude);
      maxLat = max(maxLat, location.receiverPosition.latitude);
      minLng = min(minLng, location.receiverPosition.longitude);
      maxLng = max(maxLng, location.receiverPosition.longitude);

      minLat = min(minLat, location.riderPosition.latitude);
      maxLat = max(maxLat, location.riderPosition.latitude);
      minLng = min(minLng, location.riderPosition.longitude);
      maxLng = max(maxLng, location.riderPosition.longitude);
    }

    double latDiff = maxLat - minLat;
    double lngDiff = maxLng - minLng;
    double maxDiff = max(latDiff, lngDiff);

    if (maxDiff <= 0.01) return 15.0;
    if (maxDiff <= 0.05) return 13.0;
    if (maxDiff <= 0.1) return 12.0;
    if (maxDiff <= 0.5) return 10.0;
    return 9.0;
  }

  LatLng _calculateMapCenter() {
    if (_locationMap.isEmpty) {
      return const LatLng(13.7563, 100.5018); // Default center (Bangkok)
    }

    double sumLat = 0, sumLng = 0;
    int totalPoints = _locationMap.length * 3;

    for (var location in _locationMap.values) {
      sumLat += location.riderPosition.latitude;
      sumLat += location.senderPosition.latitude;
      sumLat += location.receiverPosition.latitude;

      sumLng += location.riderPosition.longitude;
      sumLng += location.senderPosition.longitude;
      sumLng += location.receiverPosition.longitude;
    }

    return LatLng(sumLat / totalPoints, sumLng / totalPoints);
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];
    for (var location in _locationMap.values) {
      // Add sender marker
      markers.add(
        Marker(
          width: 80.0,
          height: 60.0,
          point: location.senderPosition,
          builder: (ctx) => Column(
            children: [
              const Icon(Icons.person_pin_circle, color: Colors.red, size: 30),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Text(
                      location.senderName,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '#${location.transactionId.substring(0, 6)}',
                      style: const TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      // Add receiver marker
      markers.add(
        Marker(
          width: 80.0,
          height: 60.0,
          point: location.receiverPosition,
          builder: (ctx) => Column(
            children: [
              const Icon(Icons.location_on, color: Colors.orange, size: 30),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Text(
                      location.receiverName,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '#${location.transactionId.substring(0, 6)}',
                      style: const TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      // Add rider marker
      markers.add(
        Marker(
          width: 80.0,
          height: 60.0,
          point: location.riderPosition,
          builder: (ctx) => Column(
            children: [
              Image.asset(
                'assets/images/rider.png',
                width: 30,
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Text(
                      location.riderName,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '#${location.transactionId.substring(0, 6)}',
                      style: const TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return markers;
  }

  List<Polyline> _buildRoutes() {
    return []; // Empty list - no routes will be displayed
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: Colors.black87),
          ),
        ),
      ),
    );
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
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildMapContainer(),
                ),
                const SizedBox(height: 16),
                _buildLegend(),
                const SizedBox(height: 16),
                Expanded(
                  flex: 1,
                  child: _buildOrderList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapContainer() {
    return Stack(
      children: [
        Container(
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
                zoom: _calculateZoomLevel(),
                interactiveFlags: InteractiveFlag.all,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _buildMarkers(),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            children: [
              _buildZoomButton(
                icon: Icons.add,
                onPressed: () {
                  final currentZoom = _mapController.zoom;
                  _mapController.move(
                    _mapController.center,
                    currentZoom + 1,
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildZoomButton(
                icon: Icons.remove,
                onPressed: () {
                  final currentZoom = _mapController.zoom;
                  _mapController.move(
                    _mapController.center,
                    currentZoom - 1,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Active Orders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _locationMap.length,
              itemBuilder: (context, index) {
                final transactionId = _locationMap.keys.elementAt(index);
                return ListTile(
                  leading: Image.asset(
                    'assets/images/rider.png',
                    width: 24,
                    height: 24,
                  ),
                  title: Text('Order #${transactionId.substring(0, 8)}...'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _focusOnRider(transactionId),
                  dense: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          LegendItem(
              icon: Icons.person_pin_circle,
              color: Colors.red,
              label: 'Sender'),
          LegendItem(
              icon: Icons.location_on, color: Colors.orange, label: 'Receiver'),
          LegendItem(
              icon: Icons.motorcycle, color: Colors.green, label: 'Rider'),
        ],
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const LegendItem({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
