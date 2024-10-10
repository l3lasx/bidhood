import 'package:bidhood/components/cards/itemcard.dart';
import 'package:bidhood/components/layouts/user.dart';
import 'package:flutter/material.dart';
import 'package:bidhood/components/bottomsheet/item_details_bottomsheet.dart';
import 'package:latlong2/latlong.dart';

class ParcelPage extends StatefulWidget {
  const ParcelPage({super.key});

  @override
  State<ParcelPage> createState() => _ParcelPageState();
}

class _ParcelPageState extends State<ParcelPage> {
  int itemCount = 0;
  void incrementItemCount() {
    setState(() {
      itemCount++;
    });
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
                          incrementItemCount();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: Text(
                          'รายการจัดส่งทั้งหมด ($itemCount)',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: itemCount == 0
                      ? const Center(
                          child: Text(
                            'คุณยังไม่มีการจัดส่งสินค้า',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: itemCount,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ItemCard(
                                orderId: 'ORD${index + 1}',
                                sender: 'Sender ${index + 1}',
                                receiver: 'Receiver ${index + 1}',
                                receiverAddress: 'Address ${index + 1}',
                                itemImages: const [
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s',
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s',
                                ],
                                deliveryStatus: 'Pending',
                                rider: 'Rider ${index + 1}',
                                deliveryDate: DateTime.now(),
                                completionDate: null,
                                onTap: () {
                                  showBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (BuildContext context) {
                                      return ItemDetailsDrawer(
                                        orderId: 'ORD${index + 1}',
                                        sender: 'Sender ${index + 1}',
                                        receiver: 'Receiver ${index + 1}',
                                        receiverAddress: 'Address ${index + 1}',
                                        itemImages: const [
                                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s',
                                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s',
                                        ],
                                        deliveryStatus: 'Pending',
                                        rider: 'Rider ${index + 1}',
                                        deliveryDate: DateTime.now(),
                                        completionDate: null,
                                        senderLocation: const LatLng(13.7563,
                                            100.5018), // Example coordinates for Bangkok
                                        receiverLocation: const LatLng(13.7563,
                                            100.5100), // Example coordinates
                                      );
                                    },
                                  );
                                },
                              ),
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
