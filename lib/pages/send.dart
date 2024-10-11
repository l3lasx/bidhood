import 'package:bidhood/components/layouts/user.dart';
import 'package:bidhood/services/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bidhood/components/cards/itemcard.dart'; // เพิ่ม import นี้
import 'package:bidhood/components/bottomsheet/item_details_bottomsheet.dart';
import 'package:latlong2/latlong.dart';

class SendPage extends ConsumerStatefulWidget {
  const SendPage({super.key});

  @override
  ConsumerState<SendPage> createState() => _SendPageState();
}

class _SendPageState extends ConsumerState<SendPage> {
  int totals = 0; // Initial number of items set to 0
  late Future<Map<String, dynamic>> orderList;

  Future<Map<String, dynamic>> _fetchOrderData() async {
    var result = await ref.read(orderService).getMeSender();
    final orders = result['data']?['data'];
    setState(() {
      totals = orders.length ?? 0;
    });
    return result;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final goRouterState = GoRouterState.of(context);
    if (goRouterState.uri.queryParameters['refresh'] == 'true') {
      setState(() {
        orderList = _fetchOrderData();
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return UserLayout(
      key: UniqueKey(),
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
                          onPressed: () {
                            // ใส่การทำงานของปุ่มที่ 1 ตรงนี้
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: Text(
                            'รายการจัดส่งทั้งหมด ($totals)',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .push('/send/finduser'); // ใช้เส้นทางที่ถูกต้อง
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A9876),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white),
                              SizedBox(width: 2),
                              Text('สร้างรายการ',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<Map<String, dynamic>>(
                      future: orderList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasData) {
                          final orderListData = snapshot.data?['data']?['data'];
                          if (orderListData == null ||
                              orderListData.length == 0) {
                            return const Expanded(
                                child: Center(
                                    child: Text(
                              'คุณยังไม่มีการจัดส่งสินค้า',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            )));
                          }
                          return Expanded(
                            child: ListView.builder(
                              itemCount: orderListData.length,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemBuilder: (context, index) {
                                var order = orderListData[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: ItemCard(
                                    onTap: () {
                                      showBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        builder: (BuildContext context) {
                                          return ItemDetailsDrawer(
                                            orderId: order['order_id'] ?? '',
                                            sender:
                                                order['user']['fullname'] ?? '',
                                            receiver: order['receiver']
                                                    ['fullname'] ??
                                                '',
                                            receiverAddress: order['receiver']
                                                    ['address'] ??
                                                '',
                                            itemImages: order['product_list']
                                                    .map<String>((item) =>
                                                        item['image'] as String)
                                                    .toList() ??
                                                [],
                                            deliveryStatus: 'Pending',
                                            rider: order['rider_id'] ??
                                                'ยังไม่มีไรเดอรับงาน',
                                            deliveryDate: DateTime.now(),
                                            completionDate: null,
                                            senderLocation: LatLng(
                                                order['user']['location']
                                                    ['lat'],
                                                order['user']['location']
                                                    ['long']),
                                            receiverLocation: LatLng(
                                                order['receiver']['location']
                                                    ['lat'],
                                                order['receiver']['location'][
                                                    'long']), // Example coordinates
                                          );
                                        },
                                      );
                                    },
                                    orderId: order['order_id'] ?? '',
                                    sender: order['user']['fullname'] ?? '',
                                    receiver:
                                        order['receiver']['fullname'] ?? '',
                                    receiverAddress:
                                        order['receiver']['address'] ?? '',
                                    itemImages: order['product_list']
                                            .map<String>((item) =>
                                                item['image'] as String)
                                            .toList() ??
                                        [],
                                    deliveryStatus: 'Pending',
                                    rider: order['rider_id'] ??
                                        'ยังไม่มีไรเดอรับงาน',
                                    deliveryDate: DateTime.now(),
                                    completionDate: null,
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return const Expanded(
                              child: Center(
                                  child: Text(
                            'คุณยังไม่มีการจัดส่งสินค้า',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          )));
                        }
                      }),
                ],
              ),
            ),
          )),
    );
  }
}
