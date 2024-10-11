import 'package:bidhood/components/cards/itemcardrider.dart';
import 'package:bidhood/components/layouts/user.dart';
import 'package:flutter/material.dart';
import 'package:bidhood/components/bottomsheet/item_details_bottomsheet.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bidhood/providers/auth.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});
  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  final List<Map<String, dynamic>> tasks = [
    {
      'orderId': 'TASK001',
      'pickupAddress': '123 Main St, Bangkok',
      'deliveryAddress': '456 Elm St, Bangkok',
      'pickupImage': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThmD6otXBsKXfF-ldVpx1Zw53uej5PGyKX2w&s',
    },
    {
      'orderId': 'TASK002',
      'pickupAddress': '789 Oak St, Bangkok',
      'deliveryAddress': '101 Pine St, Bangkok',
      'pickupImage': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThmD6otXBsKXfF-ldVpx1Zw53uej5PGyKX2w&s',
    },
    {
      'orderId': 'TASK003',
      'pickupAddress': '202 Maple St, Bangkok',
      'deliveryAddress': '303 Birch St, Bangkok',
      'pickupImage': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThmD6otXBsKXfF-ldVpx1Zw53uej5PGyKX2w&s',
    },
    {
      'orderId': 'TASK004',
      'pickupAddress': '404 Cedar St, Bangkok',
      'deliveryAddress': '505 Walnut St, Bangkok',
      'pickupImage': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThmD6otXBsKXfF-ldVpx1Zw53uej5PGyKX2w&s',
    },
    {
      'orderId': 'TASK005',
      'pickupAddress': '606 Spruce St, Bangkok',
      'deliveryAddress': '707 Fir St, Bangkok',
      'pickupImage': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThmD6otXBsKXfF-ldVpx1Zw53uej5PGyKX2w&s',
    },
  ];

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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: Text(
                          'รายการงานทั้งหมด (${tasks.length})',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ItemCardRider(
                        orderId: task['orderId'],
                        pickupAddress: task['pickupAddress'],
                        deliveryAddress: task['deliveryAddress'],
                        pickupImage: task['pickupImage'],
                        onViewDetails: () {
                          showBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext context) {
                              return ItemDetailsDrawer(
                                orderId: task['orderId'],
                                sender: 'Sender Name',
                                receiver: 'Receiver Name',
                                receiverAddress: task['deliveryAddress'],
                                itemImages: [task['pickupImage']],
                                deliveryStatus: 'Pending',
                                rider: 'You',
                                deliveryDate: DateTime.now(),
                                completionDate: null,
                                senderLocation: const LatLng(13.7563, 100.5018),
                                receiverLocation: const LatLng(13.7563, 100.5100),
                                userRole: userRole,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
