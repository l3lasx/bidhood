import 'package:bidhood/components/layouts/user.dart';
import 'package:bidhood/hooks/oderlist.dart';
import 'package:bidhood/services/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bidhood/providers/auth.dart';
import 'package:go_router/go_router.dart';

class ParcelPage extends ConsumerStatefulWidget {
  const ParcelPage({super.key});

  @override
  ConsumerState<ParcelPage> createState() => _ParcelPageState();
}

class _ParcelPageState extends ConsumerState<ParcelPage> {
  int totals = 0;
  late Future<Map<String, dynamic>> orderList;

  Future<Map<String, dynamic>> _fetchOrderData() async {
    var result = await ref.read(orderService).getMeReceiver();
    final orders = result['data']?['data'];
    setState(() {
      totals = orders.length ?? 0;
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

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(authProvider).userData['role'];
    return UserLayout(
      bodyWidget: Stack(children: [
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
                            'รายการที่คุณจะได้รับ ($totals)',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
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
              context.push('/parcel/groupmap');
            },
            backgroundColor: const Color(0xFF0A9876),
            child: const Icon(Icons.map, color: Colors.white),
          ),
        ),
      ]),
    );
  }
}
