import 'package:bidhood/components/layouts/user.dart';
import 'package:bidhood/hooks/oderlist.dart';
import 'package:bidhood/services/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bidhood/providers/auth.dart';

class SendPage extends ConsumerStatefulWidget {
  const SendPage({super.key});

  @override
  ConsumerState<SendPage> createState() => _SendPageState();
}

class _SendPageState extends ConsumerState<SendPage> {
  int totals = 0;
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
    final userRole = ref.watch(authProvider).userData['role'];
    return UserLayout(
      key: UniqueKey(),
      bodyWidget: Stack(
        children: [
          Positioned(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                              context.push(
                                  '/send/finduser'); // ใช้เส้นทางที่ถูกต้อง
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
                    OrderListView(
                      orderFuture: orderList,
                      userRole: userRole,
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () {
                context.push('/send/groupmap?type=send');  // Add type parameter
              },
              backgroundColor: const Color(0xFF0A9876),
              child: const Icon(Icons.map, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
