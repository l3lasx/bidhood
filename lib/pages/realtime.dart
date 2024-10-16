// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:bidhood/components/layouts/user.dart';
import 'package:bidhood/providers/rider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:bidhood/components/layouts/user.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RealTimePage extends ConsumerStatefulWidget {
  final String transactionID;
  const RealTimePage({super.key, required this.transactionID});

  @override
  ConsumerState<RealTimePage> createState() => _RealTimePageState();
}

class _RealTimePageState extends ConsumerState<RealTimePage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  bool _disposed = false;

  late Map<String, dynamic> currentTask;

  List<LatLng> _routePoints = [];
  double _distance = 0.0;
  bool _isLoading = true;
  int _currentStep = 0;

  final List<String> _steps = [
    'รับงาน',
    'เข้ารับพัสดุ',
    'รับสินค้าแล้วกำลังเดินทาง',
    'นำส่งสินค้าแล้ว'
  ];
  String? _receivePhoto;
  String? _deliveryPhoto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        startRealtimeGet();
      }
    });
    _fetchMockData();
  }

  void startRealtimeGet() {
    if (widget.transactionID.isNotEmpty) {
      final docRef = db.collection("transactions").doc(widget.transactionID);

      final notifier = ref.read(riderProvider.notifier);

      notifier.setListener(docRef.snapshots().listen(
        (event) {
          if (mounted) {
            var data = event.data();
            notifier.update(data);
            debugPrint("current data: $data");
          }
        },
        onError: (error) => debugPrint("Listen failed: $error"),
      ));
    } else {
      debugPrint("transactionID is not valid: ${widget.transactionID}");
      context.go('/');
    }
  }

  void stopRealTime() {
    if (_disposed) return;
    if (mounted) {
      final notifier = ref.read(riderProvider.notifier);
      notifier.cancel();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    stopRealTime();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   var data = ref.watch(riderProvider).data;
  //   return Scaffold(
  //     appBar: AppBar(title: const Text("Real Time Channel")),
  //     body: SafeArea(
  //       child: Center(
  //         child: data == null
  //             ? const CircularProgressIndicator()
  //             : Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text('OrderID: ${data['order_id'] ?? 'N/A'}'),
  //                   Text(
  //                       'Receiver Lat: ${data['receiver_location']?['Lat'] ?? 'N/A'}'),
  //                   Text(
  //                       'Receiver Long: ${data['receiver_location']?['Long'] ?? 'N/A'}'),
  //                   Text(
  //                       'Rider Lat: ${data['rider_location']?['Lat'] ?? 'N/A'}'),
  //                   Text(
  //                       'Rider Long: ${data['rider_location']?['Long'] ?? 'N/A'}'),
  //                   Text(
  //                       'RiderStart Lat: ${data['rider_start_location']?['Lat'] ?? 'N/A'}'),
  //                   Text(
  //                       'RiderStart Long: ${data['rider_start_location']?['Long'] ?? 'N/A'}'),
  //                   Text(
  //                       'Sender Lat: ${data['sender_location']?['Lat'] ?? 'N/A'}'),
  //                   Text(
  //                       'Sender Long: ${data['sender_location']?['Long'] ?? 'N/A'}'),
  //                   const SizedBox(height: 20),
  //                   FilledButton(
  //                     onPressed: () => context.go('/tasklist'),
  //                     child: const Text("Back"),
  //                   ),
  //                 ],
  //               ),
  //       ),
  //     ),
  //   );
  // }

  void _fetchMockData() {
    // Mock data
    currentTask = {
      'order_id': 'ORD001',
      'sender': {
        'fullname': 'John Doe',
        'address': '123 Sender St, Bangkok',
        'location': {'lat': 13.7563, 'long': 100.5018},
      },
      'receiver': {
        'fullname': 'Jane Smith',
        'address': '456 Receiver Rd, Bangkok',
        'location': {'lat': 13.7469, 'long': 100.5389},
      },
      'product_list': [
        {
          'name': 'Product 1',
          'quantity': 2,
          'image':
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThmD6otXBsKXfF-ldVpx1Zw53uej5PGyKX2w&s'
        },
        {
          'name': 'Product 2',
          'quantity': 1,
          'image':
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThmD6otXBsKXfF-ldVpx1Zw53uej5PGyKX2w&s'
        },
      ],
      'status': 'In Progress',
      'created_at': '2023-06-01T10:00:00Z',
    };
    // Set initial step to 1 (เข้ารับพัสดุ) instead of 0
    _currentStep = 1;
    _fetchRouteAndDistance();
  }

  Future<void> _fetchRouteAndDistance() async {
    setState(() {
      _isLoading = true;
    });

    final senderLocation = LatLng(
      currentTask['sender']['location']['lat'],
      currentTask['sender']['location']['long'],
    );
    final receiverLocation = LatLng(
      currentTask['receiver']['location']['lat'],
      currentTask['receiver']['location']['long'],
    );

    final response = await http.get(Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/${senderLocation.longitude},${senderLocation.latitude};${receiverLocation.longitude},${receiverLocation.latitude}?overview=full&geometries=geojson'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
      final distance = data['routes'][0]['distance'] as num;

      setState(() {
        _routePoints = coordinates
            .map((coord) => LatLng(coord[1] as double, coord[0] as double))
            .toList();
        _distance = distance / 1000; // Convert meters to kilometers
        _isLoading = false;
      });
    } else {
      print('Failed to fetch route and distance');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _capturePhoto(int step) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        if (step == 1) {
          _receivePhoto = photo.path;
        } else if (step == 3) {
          _deliveryPhoto = photo.path;
        }
      });
    }
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
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: _isLoading
                                ? Center(child: CircularProgressIndicator())
                                : FlutterMap(
                                    options: MapOptions(
                                      center: LatLng(
                                        (currentTask['sender']['location']
                                                    ['lat'] +
                                                currentTask['receiver']
                                                    ['location']['lat']) /
                                            2,
                                        (currentTask['sender']['location']
                                                    ['long'] +
                                                currentTask['receiver']
                                                    ['location']['long']) /
                                            2,
                                      ),
                                      zoom: 12.0,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        subdomains: ['a', 'b', 'c'],
                                      ),
                                      PolylineLayer(
                                        polylines: [
                                          Polyline(
                                            points: _routePoints,
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
                                            point: LatLng(
                                                currentTask['sender']
                                                    ['location']['lat'],
                                                currentTask['sender']
                                                    ['location']['long']),
                                            builder: (ctx) => Icon(
                                                Icons.location_on,
                                                color: Colors.blue),
                                          ),
                                          Marker(
                                            width: 40.0,
                                            height: 40.0,
                                            point: LatLng(
                                                currentTask['receiver']
                                                    ['location']['lat'],
                                                currentTask['receiver']
                                                    ['location']['long']),
                                            builder: (ctx) => Icon(
                                                Icons.location_on,
                                                color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.directions_car, color: Colors.blue),
                              SizedBox(width: 10),
                              Text(
                                  'Distance: ${_distance.toStringAsFixed(2)} km',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order ID: ${currentTask['order_id']}',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                          SizedBox(height: 20),
                          _buildInfoSection(
                              'Sender',
                              currentTask['sender']['fullname'],
                              currentTask['sender']['address'],
                              Icons.person),
                          SizedBox(height: 20),
                          _buildInfoSection(
                              'Receiver',
                              currentTask['receiver']['fullname'],
                              currentTask['receiver']['address'],
                              Icons.person_outline),
                          SizedBox(height: 20),
                          _buildStatusSection(
                              currentTask['status'], currentTask['created_at']),
                          SizedBox(height: 20),
                          Text('Products:',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          ...currentTask['product_list']
                              .map<Widget>((product) => Card(
                                    elevation: 2,
                                    margin: EdgeInsets.only(bottom: 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(product['image'],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover),
                                      ),
                                      title: Text(product['name'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                          'Quantity: ${product['quantity']}'),
                                      trailing: Icon(Icons.arrow_forward_ios,
                                          size: 16),
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
      String title, String name, String address, IconData icon) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              SizedBox(width: 10),
              Text('$title:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.only(left: 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 16)),
                Text(address,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(String status, String createdAt) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green),
              SizedBox(width: 10),
              Text('Status:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.only(left: 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status,
                    style: TextStyle(fontSize: 16, color: Colors.green)),
                Text('Created At: $createdAt',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                SizedBox(height: 15),
                _buildStepper(),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _updateOrderStatus,
                  child: Text(_getButtonText()),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Column(
      children: _steps.asMap().entries.map((entry) {
        final index = entry.key;
        final title = entry.value;
        final isActive = index <= _currentStep;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 30,
                child: Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? Colors.green : Colors.grey,
                      ),
                      child: Center(
                        child: Icon(
                          _getStepIcon(index),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    if (index < _steps.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                isActive ? Colors.green : Colors.grey,
                                index + 1 <= _currentStep
                                    ? Colors.green
                                    : Colors.grey,
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? Colors.black : Colors.grey,
                      ),
                    ),
                    if (index == 1 && _receivePhoto != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.file(File(_receivePhoto!),
                            height: 50, width: 50),
                      ),
                    if (index == 3 && _deliveryPhoto != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.file(File(_deliveryPhoto!),
                            height: 50, width: 50),
                      ),
                    SizedBox(height: 20), // Add space between steps
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.assignment_turned_in; // New icon for "รับงาน"
      case 1:
        return Icons.local_shipping;
      case 2:
        return Icons.directions_car;
      case 3:
        return Icons.check_circle;
      default:
        return Icons.circle;
    }
  }

  void _updateOrderStatus() {
    if (_currentStep < _steps.length - 1) {
      if (_currentStep == 1 && _receivePhoto == null) {
        _capturePhoto(1);
      } else if (_currentStep == 2) {
        setState(() {
          _currentStep++;
        });
      } else {
        setState(() {
          _currentStep++;
        });
      }
    } else if (_currentStep == _steps.length - 1) {
      if (_deliveryPhoto == null) {
        _capturePhoto(3);
      } else {
        // This is the final step and we have the delivery photo
        print('Order completed');
        // For example: await ref.read(orderService).completeOrder(currentTask['order_id']);
      }
    }

    // Here you would typically update the order status in your backend
    // For example: await ref.read(orderService).updateStatus(currentTask['order_id'], _steps[_currentStep]);
  }

  String _getButtonText() {
    if (_currentStep == 1 && _receivePhoto == null) {
      return 'ถ่ายรูปเข้ารับพัสดุ';
    } else if (_currentStep == 3 && _deliveryPhoto == null) {
      return 'ถ่ายรูปส่งพัสดุ';
    } else if (_currentStep == _steps.length - 1 && _deliveryPhoto != null) {
      return 'เสร็จสิ้นการส่ง';
    } else {
      return 'อัพเดทสถานะ';
    }
  }
}
