// ignore_for_file: avoid_init_to_null

import 'dart:async';
import 'dart:math' show sin, cos, sqrt, atan2, pi;

import 'package:bidhood/components/cards/itemcardrider.dart';
import 'package:bidhood/components/layouts/user.dart';
import 'package:bidhood/hooks/oderlist.dart';
import 'package:bidhood/services/order.dart';
import 'package:bidhood/services/rider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bidhood/components/bottomsheet/item_details_bottomsheet.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bidhood/providers/auth.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bidhood/services/user.dart';
import 'package:flutter/services.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});
  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage>
    with SingleTickerProviderStateMixin {
  int totals = 0;
  int totalsHistory = 0;
  Future<Map<String, dynamic>>? orderList;
  Future<Map<String, dynamic>>? riderHistoryList;
  late TabController _tabController;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  StreamSubscription? subscription;
  late Stream<QuerySnapshot> transactionStream;
  bool _mounted = true;
  Timer? _locationUpdateTimer;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    _initializeData();
    checkLocationPermission();
  }

  void _initializeData() {
    transactionStream = db.collection("transactions").snapshots();
    subscription = transactionStream.listen(_handleTransactionChanges);
    _refreshData();
    checkStatusAndLoadData();
  }

  void _handleTabChange() {
    if (!_mounted) return;
    _refreshData();
  }

  void _refreshData() {
    if (!_mounted) return;
    setState(() {
      orderList = _fetchOrderData();
      riderHistoryList = _fetchOrderRiderHistoryData();
    });
  }

  void _handleTransactionChanges(QuerySnapshot snapshot) {
    if (!_mounted) return;
    
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        _refreshData();
        break;
      }
    }
  }

  double _calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // รัศมีของโลกในกิโลเมตร
    
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);
    
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * 
        sin(dLon / 2) * sin(dLon / 2);
    
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // ระยะทางในกิโลเมตร
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Future<Map<String, dynamic>> _fetchOrderData() async {
    if (!_mounted) return {'data': null};
    
    try {
      var user = ref.watch(authProvider).userData;
      var result = await ref.read(orderService).getAllByLocation(
        _currentPosition?.latitude ?? user['location']['lat'],
        _currentPosition?.longitude ?? user['location']['long']
      );
      
      if (!_mounted) return result;
      
      // Calculate distances using current position
      if (result['data']?['data'] != null) {
        var orders = result['data']['data'] as List;
        for (var order in orders) {
          double riderLat = _currentPosition?.latitude ?? user['location']['lat'];
          double riderLong = _currentPosition?.longitude ?? user['location']['long'];
          double senderLat = order['user']['location']['lat'];
          double senderLong = order['user']['location']['long'];

          order['rider_goto_sender_distance'] = _calculateHaversineDistance(
            riderLat, 
            riderLong, 
            senderLat, 
            senderLong
          );
        }
      }

      final orders = (result['data']?['data'] as List?)?.where((order) {
        return order['status'] == 1;
      }).toList() ?? [];

      setState(() {
        if (_mounted) totals = orders.length;
      });
      
      return result;
    } catch (e) {
      debugPrint('Error fetching order data: $e');
      return {'data': null};
    }
  }

  Future<Map<String, dynamic>> _fetchOrderRiderHistoryData() async {
    if (!_mounted) return {'data': {'data': []}};

    try {
      var result = await ref.read(orderService).getMeRider();
      
      if (!_mounted) return result;

      if (result != null &&
          result['data'] != null &&
          result['data']['data'] != null) {
        final orders = result['data']['data'] as List;
        setState(() {
          if (_mounted) totalsHistory = orders.length;
        });
      } else {
        setState(() {
          if (_mounted) totalsHistory = 0;
        });
      }
      return result;
    } catch (e) {
      debugPrint('Error fetching rider history: $e');
      setState(() {
        if (_mounted) totalsHistory = 0;
      });
      return {'data': {'data': []}};
    }
  }

  Future<void> checkStatusAndLoadData() async {
    if (!_mounted) return;

    try {
      await redirectToAlreadyWork();
      setState(() {
        if (_mounted) orderList = _fetchOrderData();
      });
    } catch (e) {
      debugPrint('Error checking status or loading data: $e');
    }
  }

  Future<void> redirectToAlreadyWork() async {
    if (!_mounted) return;

    var checkWork = await ref.read(riderService).checkCurrentWork();
    if (checkWork["statusCode"] != 200) {
      if (checkWork['data'] != null) {
        debugPrint('${checkWork['data']}');
        debugPrint("กำลังพาไปยังงานล่าสุดของคุณ!");
      }
      var orders = checkWork['data']['orders'];
      if (orders.length > 0) {
        goToRealtime(orders[0]["order_transaction_id"], orders[0]['order_id']);
      }
    }
  }

  Future<void> riderAcceptWork(dynamic task) async {
    if (!_mounted) return;

    var checkWork = await ref.read(riderService).checkCurrentWork();
    if (checkWork["statusCode"] != 200) {
      if (checkWork['data'] != null) {
        debugPrint('${checkWork['data']}');
        debugPrint("ดูเหมือนว่า rider จะรับงานค้างอยู่แล้ว");
        AlertController.show(
          "เกิดข้อผิดพลาด",
          "${checkWork['data']['message']}",
          TypeAlert.warning
        );
      }
      var orders = checkWork['data']['orders'];
      if (orders.length > 0) {
        goToRealtime(orders[0]["order_transaction_id"], task['order_id']);
      }
      return;
    }

    var acceptWork = await ref.read(riderService).acceptWork(task['order_id']);
    if (acceptWork["statusCode"] != 200) {
      debugPrint('${acceptWork['data']}');
      debugPrint("รับงานไม่สำเร็จ");
      AlertController.show(
        "รับงานไม่สำเร็จ",
        "${acceptWork['data']['message']}",
        TypeAlert.error
      );
      return;
    }

    var work = acceptWork['data'];
    var transactionID = work['data']['order_transaction_id'];
    
    if (transactionID != null && _mounted) {
      AlertController.show(
        "รับงานสำเร็จ",
        "${acceptWork['data']['message']}",
        TypeAlert.success
      );
      goToRealtime(transactionID, task['order_id']);
    }
  }

  void goToRealtime(String id, String orderId) {
    if (!_mounted) return;
    context.go('/realtime', extra: {'transactionID': id, 'orderID': orderId});
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(text: 'งานที่ยังไม่รับ'),
            Tab(text: 'งานที่สำเร็จ'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(dynamic task) {
    return ItemCardRider(
      orderId: task['order_id'],
      rider_goto_sender_distance: task['rider_goto_sender_distance'].toDouble(),
      pickupAddress: task['user']['address'],
      deliveryAddress: task['receiver']['address'],
      pickupImage: task['events'][0]['event_picture'],
      onViewDetails: () => _showOrderDetails(task),
    );
  }

  void _showOrderDetails(dynamic task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return ItemDetailsDrawer(
              transactionID: task['order_transaction_id'],
              orderId: task['order_id'],
              sender: task['user']['fullname'],
              receiver: task['receiver']['fullname'],
              receiverAddress: task['receiver']['address'],
              itemImages: (task['product_list'] as List<dynamic>)
                  .map<String>((item) => item['image'].toString())
                  .toList(),
              deliveryStatus: task['status'] ?? 0,
              des: (task['product_list'] as List<dynamic>)
                  .map<String>((item) => item['description'].toString())
                  .toList(),
              rider: 'You',
              deliveryDate: DateTime.now(),
              completionDate: null,
              isCompleted: task['is_order_complete'] ?? false,
              receiverLocation: LatLng(
                task['receiver']['location']['lat'].toDouble(),
                task['receiver']['location']['long'].toDouble(),
              ),
              senderLocation: LatLng(
                task['user']['location']['lat'].toDouble(),
                task['user']['location']['long'].toDouble(),
              ),
              userRole: ref.watch(authProvider).userData['role'],
              onAcceptJob: () async {
                if (task["order_transaction_id"] == null) return;
                await riderAcceptWork(task);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOrderList() {
    return FutureBuilder<Map<String, dynamic>>(
      future: orderList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data?['data'] == null) {
          return _buildEmptyState();
        }

        final orderListData = (snapshot.data!['data']['data'] as List?)
            ?.where((order) => 
                order['status'] == 1 && 
                order['rider_goto_sender_distance'] <= 0.02 // 20 เมตร = 0.02 กิโลเมตร
            )
            .toList() ?? [];

        if (orderListData.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          itemCount: orderListData.length,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemBuilder: (context, index) => _buildOrderItem(orderListData[index]),
        );
      },
    );
  }

  Widget _buildHistoryList() {
    return Column(
      children: [
        if (riderHistoryList != null)
          OrderListView(
            orderFuture: riderHistoryList!,
            userRole: ref.watch(authProvider).userData['role'],
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'ขออภัยไม่มีรายการของคุณ',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Text(
        'เกิดข้อผิดพลาด: $error',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: transactionStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return UserLayout(
          showBackButton: false,
          bodyWidget: SafeArea(
            child: Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrderList(),
                      _buildHistoryList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _mounted = false;
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    subscription?.cancel();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  void startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await updateRiderLocation();
      // Refresh order list to recalculate distances
      _refreshData();
    });
  }

  Future<void> updateRiderLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        throw Exception("Location permission denied");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Store current position
      setState(() {
        _currentPosition = position;
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
      if (e.toString().contains("Location permission denied")) {
        checkLocationPermission();
      }
    }
  }

  Future<void> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ตรวจสอบว่า location service เปิดอยู่หรือไม่
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AlertController.show(
        "Location Service ปิดอยู่", 
        "กรุณาเปิด Location Service เพื่อใช้งาน", 
        TypeAlert.warning
      );
      SystemNavigator.pop(); // ออกจากแอป
      return;
    }

    // ตรวจสอบ permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // ถ้ายังไม่เคยขอ permission ให้ขอ
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AlertController.show(
          "ไม่ได้รับอนุญาต", 
          "ไม่สามารถเข้าถึงตำแหน่งได้เนื่องจากไม่ได้รับอนุญาต", 
          TypeAlert.error
        );
        SystemNavigator.pop(); // ออกจากแอป
        return;
      }
    }

    // ถ้าถูก denied forever
    if (permission == LocationPermission.deniedForever) {
      AlertController.show(
        "ไม่ได้รับอนุญาต", 
        "กรุณาเปิดการอนุญาตการเข้าถึงตำแหน่งในการตั้งค่า", 
        TypeAlert.error
      );
      SystemNavigator.pop(); // ออกจากแอป
      return;
    }

    // ถ้าได้รับอนุญาตแล้ว เริ่มการอัพเดทตำแหน่ง
    startLocationUpdates();
  }
}
