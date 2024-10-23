// ignore_for_file: avoid_init_to_null

import 'package:bidhood/components/cards/itemcardrider.dart';
import 'package:bidhood/components/layouts/user.dart';
import 'package:bidhood/hooks/oderlist.dart';
import 'package:bidhood/services/order.dart';
import 'package:bidhood/services/rider.dart';
import 'package:flutter/material.dart';
import 'package:bidhood/components/bottomsheet/item_details_bottomsheet.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bidhood/providers/auth.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});
  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage>
    with SingleTickerProviderStateMixin {
  int totals = 0;
  int totalsHistory = 0;
  late dynamic orderList = null;
  late dynamic riderHistoryList = null;
  late TabController _tabController;

  Future<Map<String, dynamic>> _fetchOrderData() async {
    var user = ref.watch(authProvider).userData;
    var result = await ref
        .read(orderService)
        .getAllByLocation(user['location']['lat'], user['location']['long']);
    final orders = (result['data']?['data'] as List).where((order) {
      return order['status'] == 1 &&
          (order['rider_goto_sender_distance'] * 1000) <= 20;
    }).toList();
    setState(() {
      totals = orders.length;
    });
    return result;
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        orderList = _fetchOrderData();
        riderHistoryList = _fetchOrderRiderHistoryData();
      });
    });
    checkStatusAndLoadData();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> checkStatusAndLoadData() async {
    try {
      await redirectToAlreadyWork();
      setState(() {
        orderList = _fetchOrderData();
      });
    } catch (e) {
      debugPrint('Error checking status or loading data: $e');
    }
  }

  Future<void> redirectToAlreadyWork() async {
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
    var checkWork = await ref.read(riderService).checkCurrentWork();
    if (checkWork["statusCode"] != 200) {
      if (checkWork['data'] != null) {
        debugPrint('${checkWork['data']}');
        debugPrint("ดูเหมือนว่า rider จะรับงานค้างอยู่แล้ว");
        AlertController.show("เกิดข้อผิดพลาด",
            "${checkWork['data']['message']}", TypeAlert.warning);
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
      AlertController.show("รับงานไม่สำเร็จ",
          "${acceptWork['data']['message']}", TypeAlert.error);
      return;
    }
    debugPrint('${acceptWork['statusCode']}');
    debugPrint('${acceptWork['data']}');
    var work = acceptWork['data'];
    var transactionID = work['data']['order_transaction_id'];
    debugPrint(transactionID);
    if (transactionID != null) {
      AlertController.show("รับงานสำเร็จ", "${acceptWork['data']['message']}",
          TypeAlert.success);
      goToRealtime(transactionID, task['order_id']);
    }
  }

  Future<Map<String, dynamic>> _fetchOrderRiderHistoryData() async {
    try {
      var result = await ref.read(orderService).getMeRider();
      debugPrint('result: $result');

      // ตรวจสอบโครงสร้างข้อมูลที่ได้
      if (result != null &&
          result['data'] != null &&
          result['data']['data'] != null) {
        final orders = result['data']['data'] as List;
        setState(() {
          totalsHistory = orders.length;
        });
      } else {
        setState(() {
          totalsHistory = 0;
        });
      }
      return result;
    } catch (e) {
      debugPrint('Error fetching rider history: $e');
      setState(() {
        totalsHistory = 0;
      });
      return {
        'data': {'data': []}
      };
    }
  }

  void goToRealtime(id, orderId) {
    context.go('/realtime', extra: {'transactionID': id, 'orderID': orderId});
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return 'งานที่ยังไม่รับ';
      case 1:
        return 'งานที่สำเร็จ';
      default:
        return '';
    }
  }

  Widget _buildOrderList() {
    return FutureBuilder<dynamic>(
      future: orderList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final orderListData =
              (snapshot.data?['data']?['data'] as List?)?.where((order) {
                    return order['status'] == 1 &&
                        (order['rider_goto_sender_distance'] * 1000) <= 20;
                  }).toList() ??
                  [];

          if (orderListData.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: orderListData.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final task = orderListData[index];
              return ItemCardRider(
                orderId: task['order_id'],
                rider_goto_sender_distance:
                    task['rider_goto_sender_distance'].toDouble(),
                pickupAddress: task['user']['address'],
                deliveryAddress: task['receiver']['address'],
                pickupImage: task['events'][0]['event_picture'],
                onViewDetails: () {
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
                                .map<String>(
                                    (item) => item['description'].toString())
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
                              debugPrint('Job accepted: ');
                              if (task["order_transaction_id"] == null) {
                                return;
                              }
                              await riderAcceptWork(task);
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        } else {
          return _buildEmptyState();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(authProvider).userData['role'];
    return UserLayout(
      showBackButton: false,
      bodyWidget: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
              child: Column(
                children: [
                  Container(
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
                      tabs: [0, 1].map((index) {
                        return Tab(text: _getTabTitle(index));
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrderList(),
                  Column(
                    children: [
                      riderHistoryList != null
                          ? OrderListView(
                              orderFuture: riderHistoryList,
                              userRole: userRole,
                            )
                          : Container()
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
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
}
