// ignore_for_file: invalid_use_of_visible_for_testing_member, no_leading_underscores_for_local_identifiers, depend_on_referenced_packages, unnecessary_import, use_build_context_synchronously

import 'dart:async';
import 'package:bidhood/components/maproute/mapbox.dart';
import 'package:bidhood/providers/auth.dart';
import 'package:bidhood/providers/rider.dart';
import 'package:bidhood/services/order.dart';
import 'package:bidhood/services/rider.dart';
import 'package:bidhood/services/upload.dart';
import 'package:bidhood/services/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RealTimePage extends ConsumerStatefulWidget {
  final String transactionID;
  final String orderID;
  const RealTimePage(
      {super.key, required this.transactionID, required this.orderID});

  @override
  ConsumerState<RealTimePage> createState() => _RealTimePageState();
}

class _RealTimePageState extends ConsumerState<RealTimePage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  bool _disposed = false;
  Map<String, dynamic> routesMap = {};
  Map<String, dynamic> orderDetail = {};
  Map<String, dynamic> currentWork = {};

  final GlobalKey<MapBoxState> mapBoxKey = GlobalKey<MapBoxState>();

  bool isLoading = true;
  Timer? _locationUpdateTimer;
  int _currentStep = 0;

  final double _stepIconSize = 30;
  final double _stepImageSize = 100;
  final double _stepSpacing = 20;

  final List<String> _steps = [
    'รอไรเดอร์มารับสินค้า',
    'ไรเดอร์รับงาน',
    'ไรเดอร์เข้ารับพัสดุ',
    'รับสินค้าแล้วกำลังเดินทาง',
    'นำส่งสินค้าแล้ว'
  ];

  final Color mainColor = const Color(0xFF0A9830);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        startRealtimeGet();
        setupOrder();
        startLocationUpdates();
      }
    });
  }

  void startRealtimeGet() {
    if (widget.transactionID.isNotEmpty) {
      final docRef = db.collection("transactions").doc(widget.transactionID);

      final notifier = ref.read(riderProvider.notifier);

      notifier.setListener(docRef.snapshots().listen(
        (event) {
          if (mounted) {
            var data = event.data();
            debugPrint('status is a ${data?["status"]}');

            if (!isRiderInWork()) {
              var status = data?['status'] ?? 0;
              if (status >= 2 && status != _currentStep) {
                setupOrder();
                debugPrint("Update Status By Rider");
              }
            }

            notifier.update(data);
            setState(() {
              currentWork = data!;
            });
          }
        },
        onError: (error) => debugPrint("Listen failed: $error"),
      ));
    } else {
      debugPrint("transactionID is not valid: ${widget.transactionID}");
      context.go('/');
    }
  }

  void startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (isRiderInWork()) {
        updateRiderLocation();
        mapBoxKey.currentState?.focusUpdate();
      } else {
        debugPrint("อัพเดทตำแหน่ง:: ไม่ใช่ Rider ของงานนี้");
      }
    });
  }

  Future<void> updateRiderLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await db.collection("transactions").doc(widget.transactionID).update({
        'rider_location': {
          'Lat': position.latitude,
          'Long': position.longitude,
        },
      });

      Map<String, dynamic> payload = {
        "location": {"lat": position.latitude, "long": position.longitude}
      };

      var updateProfile = await ref.watch(userService).update(payload);
      if (updateProfile['statusCode'] == 200) {
        ref
            .read(authProvider.notifier)
            .updateUser(updateProfile['data']['data']);
      }

      debugPrint(
          "Rider location updated: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      debugPrint("Error updating rider location: $e");
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
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  String? _receivePhoto;
  String? _deliveryPhoto;
  String? _successPhoto;
  String? _senderPhoto;

  Future<void> setupOrder() async {
    try {
      var response = await fetchOrderDetails();
      if (response['statusCode'] == 200) {
        final orderData = response['data']['data'];

        setState(() {
          orderDetail = orderData;
          _currentStep = (((orderData['status'] as int?) ?? 0));
          debugPrint("Current step is : $_currentStep");
          _processEvents();
        });

        await calculateRoutes();
      } else {
        debugPrint("Failed to fetch order details: ${response['statusCode']}");
        // Consider showing an error message to the user
      }
    } catch (e) {
      debugPrint("Error in setupOrder: $e");
      // Consider showing an error message to the user
    }
  }

  void _processEvents() {
    final List<dynamic>? events = orderDetail['events'] as List<dynamic>?;
    if (events == null || events.isEmpty) {
      debugPrint('No events found');
      return;
    }

    for (var event in events) {
      if (event is! Map<String, dynamic>) {
        debugPrint('Invalid event format: $event');
        continue;
      }

      final String eventName = event['name'] as String? ?? '';
      final String? eventPicture = event['event_picture'] as String?;
      switch (eventName) {
        case 'รอไรเดอร์มารับสินค้า':
          _senderPhoto = eventPicture;
        case 'ไรเดอร์เข้ารับพัสดุ':
          _receivePhoto = eventPicture;
          break;
        case 'รับสินค้าแล้วกำลังเดินทาง':
          _deliveryPhoto = eventPicture;
          break;
        case 'นำส่งสินค้าแล้ว':
          _successPhoto = eventPicture;
          break;
        default:
          debugPrint('Unhandled event: $eventName');
      }
    }
  }

  Future<Map<String, dynamic>> fetchOrderDetails() async {
    return await ref.read(orderService).getOrderByID(widget.orderID);
  }

  bool isRiderInWork() {
    var currentUser = ref.read(authProvider).userData;
    return (currentUser['user_id'] == currentWork['rider_id']);
  }

  Future<void> calculateRoutes() async {
    var riderLocation = orderDetail['rider']?['location'];
    var senderLocation = orderDetail['user']?['location'];
    var receiverLocation = orderDetail['receiver']?['location'];

    if (riderLocation != null &&
        senderLocation != null &&
        receiverLocation != null) {
      var riderToSender = await findDistance(riderLocation['lat'],
          riderLocation['long'], senderLocation['lat'], senderLocation['long']);
      var riderToReceiver = await findDistance(
          senderLocation['lat'],
          senderLocation['long'],
          receiverLocation['lat'],
          receiverLocation['long']);

      setState(() {
        routesMap['rider_to_sender'] = riderToSender;
        routesMap['rider_to_receiver'] = riderToReceiver;
      });

      ref.read(riderProvider.notifier).updateRoutePoints(routesMap);
      debugPrint("Routes calculated: $routesMap");
    }
  }

  Future<Map<String, dynamic>> findDistance(
      double startLat, double startLong, double endLat, double endLong) async {
    final response = await http.get(Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/$startLong,$startLat;$endLong,$endLat?overview=full&geometries=geojson'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
      final distance = data['routes'][0]['distance'] as num;
      return {
        "isError": false,
        "distance": (distance / 1000),
        "routePoints": coordinates
            .map((coord) => LatLng(coord[1] as double, coord[0] as double))
            .toList()
      };
    }
    return {"isError": true, "routePoints": [], "distance": -1};
  }

  Future<void> _capturePhoto(int step) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      var upload = await ref.watch(uploadService).uploadImage(photo);
      if (upload['statusCode'] == 200) {
        var res = upload['data'];
        setState(() {
          if (step == 2) {
            _receivePhoto = res['url'];
          } else if (step == 3) {
            _deliveryPhoto = res['url'];
          } else if (step == 4) {
            _successPhoto = res['url'];
          }
        });
      }
    }
  }

  Future<void> updateWork(Map<String, dynamic> data) async {
    var response =
        await ref.read(riderService).updateWork(widget.orderID, data);
    if (response['statusCode'] != 200) {
      AlertController.show("เกิดข้อผิดพลาด", "${response['data']['message']}",
          TypeAlert.warning);
      return;
    }

    setState(() {
      _currentStep++;
    });

    try {
      await db.collection("transactions").doc(widget.transactionID).update({
        'status': _currentStep,
      });
    } catch (e) {
      debugPrint("Error updating status order: $e");
    }

    if (_currentStep == 5) {
      context.go('/tasklist');
      _disposed = true;
      stopRealTime();
      _locationUpdateTimer?.cancel();
    }

    debugPrint("${response['data']['data']}");
  }

  @override
  Widget build(BuildContext context) {
    var data = ref.watch(riderProvider).data;
    var pointers = ref.watch(riderProvider).routePoints;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
          leading: null,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_basket,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'BidHood',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data != null) ...[
                      buildMapBox(data, pointers),
                      if (orderDetail != {})
                        buildInfoBox()
                      else
                        const Center(child: CircularProgressIndicator()),
                    ] else
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  Widget buildMapBox(
      Map<String, dynamic> data, Map<String, dynamic>? pointers) {
    int status = int.tryParse(orderDetail['status']?.toString() ?? '') ?? 0;
    return MapBox(
      mapType: "rider",
      key: mapBoxKey,
      focusMapCenter: getLatLng(data['rider_location']),
      riderLocation: getLatLng(data['rider_location']),
      senderLocation: getLatLng(data['sender_location']),
      receiverLocation: getLatLng(data['receiver_location']),
      noteHint: getNoteHint(status),
      routePoints: getRoutePoints(status, pointers),
      distance: getDistance(status, pointers),
      orderStatus: status,
    );
  }

  LatLng getLatLng(Map<String, dynamic>? location) {
    return LatLng(location?['Lat'] ?? 0.0, location?['Long'] ?? 0.0);
  }

  String getNoteHint(int status) {
    if (status == 2) return "ระยะทางจากไรเดอร์ไปหาผู้ส่ง";
    if (status > 2) return "ระยะทางจากผู้ส่งไปหาผู้รับ";
    return "รอรับออเดอร์";
  }

  List<LatLng> getRoutePoints(int status, Map<String, dynamic>? pointers) {
    if (status == 2) return pointers?['rider_to_sender']?['routePoints'] ?? [];
    if (status > 2) return pointers?['rider_to_receiver']?['routePoints'] ?? [];
    return const [];
  }

  double getDistance(int status, Map<String, dynamic>? pointers) {
    if (status == 2) {
      return double.tryParse(
              pointers?['rider_to_sender']?['distance']?.toString() ?? '') ??
          0.0;
    }
    if (status > 2) {
      return double.tryParse(
              pointers?['rider_to_receiver']?['distance']?.toString() ?? '') ??
          0.0;
    }
    return 0.0;
  }

  Widget buildInfoBox() {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Order ID: ${orderDetail['order_id'] ?? 'N/A'}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              const SizedBox(height: 20),
              _buildInfoSection(
                  'ผู้ส่ง',
                  orderDetail['user']?['fullname'] ?? 'N/A',
                  'ที่อยู่ ${orderDetail['user']?['address']}' ?? 'N/A',
                  Icons.person),
              const SizedBox(height: 20),
              _buildInfoSection(
                  'ผู้รับ',
                  orderDetail['receiver']?['fullname'] ?? 'N/A',
                  'ที่อยู่ ${orderDetail['receiver']?['address']}' ?? 'N/A',
                  Icons.person_outline),
              const SizedBox(height: 20),
              if (!isRiderInWork() && orderDetail['rider_id'] != null) ...[
                _buildInfoSection(
                    'ไรเดอร์',
                    orderDetail['rider']?['fullname'] ?? 'N/A',
                    'ป้ายทะเบียน ${orderDetail['rider']?['car_plate']}' ??
                        'N/A',
                    Icons.motorcycle)
              ],
              const SizedBox(height: 20),
              const Text('สินค้าทั้งหมด :',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildInfoOrderItem(
                  orderDetail['product_list'] as List<dynamic>?),
              _buildStatusSection(orderDetail['status'] ?? 0),
            ])));
  }

  Widget _buildInfoSection(
      String title, String name, String address, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
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
              const SizedBox(width: 10),
              Text('$title:',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16)),
                if (address.isNotEmpty) ...[
                  Text(address,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoOrderItem(List<dynamic>? productList) {
    if (productList == null || productList.isEmpty) {
      return const Card(
        child: ListTile(
          title: Text('No products available'),
        ),
      );
    }

    return Column(
      children: productList.map<Widget>((product) {
        final String description = product['description'] ?? 'Unknown Product';
        final String imageUrl = product['image'] ?? '';
        final int quantity = product['quantity'] ?? 1;
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.grey[50],
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 50);
                      },
                    )
                  : const Icon(Icons.image_not_supported, size: 50),
            ),
            title: Text(
              description,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('จำนวน: $quantity'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusSection(int status) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green),
              SizedBox(width: 10),
              Text('สถานะออเดอร์',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepper(),
                const SizedBox(height: 15),
                (isRiderInWork() && _currentStep <= _steps.length - 1)
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: _updateOrderStatus,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                          ),
                          child: Text(_getButtonText()),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go("/parcel");
                          }
                        },
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "ย้อนกลับ",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ])),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    if (_currentStep == 2 && _receivePhoto == null) {
      return 'ถ่ายรูปเข้ารับพัสดุ';
    } else if (_currentStep == 3 && _deliveryPhoto == null) {
      return 'ถ่ายรูปกำลังเดินทาง';
    } else if (_currentStep == 4 && _successPhoto == null) {
      return 'ถ่ายรูปส่งพัสดุ';
    } else if (_currentStep == _steps.length - 1 && _successPhoto != null) {
      return 'เสร็จสิ้นการส่ง';
    } else {
      return 'อัพเดทสถานะ';
    }
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
                width: _stepIconSize,
                child: Column(
                  children: [
                    Container(
                      width: _stepIconSize,
                      height: _stepIconSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? Colors.green : Colors.grey,
                      ),
                      child: Center(
                        child: Icon(
                          _getStepIcon(index),
                          color: Colors.white,
                          size: 20,
                          semanticLabel: 'Step ${index + 1} icon',
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
              const SizedBox(width: 10),
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
                    if (index == 0) _buildStepImage(_senderPhoto),
                    if (index == 2) _buildStepImage(_receivePhoto),
                    if (index == 3) _buildStepImage(_deliveryPhoto),
                    if (index == 4) _buildStepImage(_successPhoto),
                    SizedBox(height: _stepSpacing),
                    // Text('$index $isActive')
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepImage(String? imageUrl) {
    if (imageUrl == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: _stepImageSize,
          height: _stepImageSize,
          fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.account_box_rounded;
      case 1:
        return Icons.assignment_turned_in;
      case 2:
        return Icons.local_shipping;
      case 3:
        return Icons.motorcycle;
      case 4:
        return Icons.check_circle;
      default:
        return Icons.circle;
    }
  }

  void _updateOrderStatus() {
    if (_currentStep < _steps.length - 1) {
      if (_currentStep == 2 && _receivePhoto == null) {
        _capturePhoto(2);
      } else if (_currentStep == 3 && _deliveryPhoto == null) {
        _capturePhoto(3);
      } else {
        switch (_currentStep) {
          case 2:
            if (_receivePhoto != null) {
              updateWork({
                "name": _steps[_currentStep].toString(),
                "status": 3,
                "picture": _receivePhoto.toString()
              });
            }
            break;
          case 3:
            if (_deliveryPhoto != null) {
              updateWork({
                "name": _steps[_currentStep].toString(),
                "status": 4,
                "picture": _deliveryPhoto.toString()
              });
            }
            break;
        }
      }
    } else if (_currentStep == _steps.length - 1) {
      if (_successPhoto == null) {
        _capturePhoto(4);
      } else {
        if (_successPhoto != null) {
          updateWork({
            "name": _steps[_currentStep].toString(),
            "status": 5,
            "picture": _successPhoto.toString(),
          });
        } else {
          context.go('/tasklist');
        }
      }
    }
    debugPrint("$_currentStep");
  }
}
