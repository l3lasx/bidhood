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
  // final List<Map<String, dynamic>> tasks = [
  //   {
  //     'orderId': 'TASK001',
  //     'pickupAddress': '123 Main St, Bangkok',
  //     'deliveryAddress': '456 Elm St, Bangkok',
  //     'pickupImage':
  //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThmD6otXBsKXfF-ldVpx1Zw53uej5PGyKX2w&s',
  //   },
  //   {
  //     'orderId': 'TASK002',
  //     'pickupAddress': '789 Oak St, Bangkok',
  //     'deliveryAddress': '101 Pine St, Bangkok',
  //     'pickupImage':
  //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThmD6otXBsKXfF-ldVpx1Zw53uej5PGyKX2w&s',
  //   },
  //   {
  //     'orderId': 'TASK003',
  //     'pickupAddress': '202 Maple St, Bangkok',
  //     'deliveryAddress': '303 Birch St, Bangkok',
  //     'pickupImage':
  //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThmD6otXBsKXfF-ldVpx1Zw53uej5PGyKX2w&s',
  //   },
  //   {
  //     'orderId': 'TASK004',
  //     'pickupAddress': '404 Cedar St, Bangkok',
  //     'deliveryAddress': '505 Walnut St, Bangkok',
  //     'pickupImage':
  //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThmD6otXBsKXfF-ldVpx1Zw53uej5PGyKX2w&s',
  //   },
  //   {
  //     'orderId': 'TASK005',
  //     'pickupAddress': '606 Spruce St, Bangkok',
  //     'deliveryAddress': '707 Fir St, Bangkok',
  //     'pickupImage':
  //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThmD6otXBsKXfF-ldVpx1Zw53uej5PGyKX2w&s',
  //   },
  // ];

  int totals = 0;
  late Future<Map<String, dynamic>> orderList;
  Future<Map<String, dynamic>> _fetchOrderData() async {
    var result = await ref.read(orderService).getAll();
    final orders = (result['data']?['data'] as List)
        .where((order) => order['status'] == 1)
        .toList();
    setState(() {
      totals = orders.length | 0;
    });
    return result;
  }

  @override
  void initState() {
    super.initState();
    orderList = _fetchOrderData();
  }

  @override
  void dispose() {
    super.dispose();
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
        goToRealtime(orders[0]["order_transaction_id"]);
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
      goToRealtime(transactionID);
    }
    return;
  }

  void goToRealtime(id) {
    context.go('/realtime', extra: {'transactionID': id});
  }

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(authProvider).userData['role'];
    return UserLayout(
      bodyWidget: Positioned(
        top: 50,
        left: 0,
        right: 0,
        bottom: 0,
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: Text(
                          'รายการงานทั้งหมด ($totals)',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<Map<String, dynamic>>(
                  future: orderList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData) {
                      final orderListData =
                          (snapshot.data?['data']?['data'] as List)
                              .where((order) => order['status'] == 1)
                              .toList();
                      if (orderListData.isEmpty) {
                        return _buildEmptyState();
                      }
                      return Expanded(
                        child: ListView.builder(
                          itemCount: orderListData.length,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemBuilder: (context, index) {
                            final task = orderListData[index];
                            return ItemCardRider(
                              orderId: task['order_id'],
                              pickupAddress: task['user']['address'],
                              deliveryAddress: task['receiver']['address'],
                              pickupImage: task['events'][0]['event_picture'],
                              onViewDetails: () {
                                showBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return ItemDetailsDrawer(
                                      orderId: task['order_id'],
                                      sender: task['user']['fullname'],
                                      receiver: task['receiver']['fullname'],
                                      receiverAddress: task['receiver']
                                          ['address'],
                                      itemImages: (task['product_list']
                                          .map<String>((item) {
                                        return item['image'].toString();
                                      })).toList(),
                                      deliveryStatus: task['status'].toString(),
                                      rider: 'You',
                                      deliveryDate: DateTime.now(),
                                      completionDate: null,
                                      senderLocation: LatLng(
                                        task['user']['location']['lat'],
                                        task['user']['location']['long'],
                                      ),
                                      receiverLocation: LatLng(
                                        task['receiver']['location']['lat'],
                                        task['receiver']['location']['long'],
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
                        ),
                      );
                    } else {
                      return _buildEmptyState();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Expanded(
      child: Center(
        child: Text(
          'ขออภัยไม่มีรายการของคุณ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
