// ignore_for_file: avoid_init_to_null

import 'package:bidhood/components/cards/itemcardrider.dart';
import 'package:bidhood/components/layouts/user.dart';
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

class _TaskListPageState extends ConsumerState<TaskListPage> {
  int totals = 0;
  late dynamic orderList = null;

  Future<Map<String, dynamic>> _fetchOrderData() async {
    var user = ref.watch(authProvider).userData;
    var result = await ref
        .read(orderService)
        .getAllByLocation(user['location']['lat'], user['location']['long']);
    final orders = (result['data']?['data'] as List)
        .where((order) => order['status'] == 1)
        .toList();
    setState(() {
      totals = orders.length;
    });
    return result;
  }

  @override
  void initState() {
    checkStatusAndLoadData();
    super.initState();
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

  void goToRealtime(id, orderId) {
    context.go('/realtime', extra: {'transactionID': id, 'orderID': orderId});
  }

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(authProvider).userData['role'];
    return UserLayout(
      showBackButton: false,
      bodyWidget: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 50, left: 16, right: 16, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: Text(
                        'รายการงานทั้งหมด ($totals)',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<dynamic>(
                future: orderList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    final orderListData =
                        (snapshot.data?['data']?['data'] as List?)
                                ?.where((order) => order['status'] == 1)
                                .toList() ??
                            [];
                    if (orderListData.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      itemCount: orderListData.length,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        final task = orderListData[index];
                        return ItemCardRider(
                          orderId: task['order_id'],
                          rider_goto_sender_distance:
                              task['rider_goto_sender_distance'],
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
                                      transactionID:
                                          task['order_transaction_id'],
                                      orderId: task['order_id'],
                                      sender: task['user']['fullname'],
                                      receiver: task['receiver']['fullname'],
                                      receiverAddress: task['receiver']
                                          ['address'],
                                      itemImages: (task['product_list']
                                              as List<dynamic>)
                                          .map<String>((item) =>
                                              item['image'].toString())
                                          .toList(),
                                      deliveryStatus: task['status'] ?? 0,
                                      rider: 'You',
                                      deliveryDate: DateTime.now(),
                                      completionDate: null,
                                      receiverLocation: LatLng(
                                        task['receiver']['location']['lat'],
                                        task['receiver']['location']['long'],
                                      ),
                                      senderLocation: LatLng(
                                        task['user']['location']['lat'],
                                        task['user']['location']['long'],
                                      ),
                                      userRole: userRole,
                                      onAcceptJob: () async {
                                        debugPrint('Job accepted: ');
                                        if (task["order_transaction_id"] ==
                                            null) {
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
