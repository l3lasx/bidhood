import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bidhood/components/cards/itemcard.dart'; // เพิ่ม import นี้

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final Color mainColor = const Color(0xFF0A9830);
  final String userName = "John Doe"; // สมมติชื่อผู้ใช้
  int itemCount = 0; // Initial number of items set to 0

  void incrementItemCount() {
    setState(() {
      itemCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
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
            GestureDetector(
              onTap: () {
                context.go('/profile'); // สมมติว่ามีหน้าโปรไฟล์
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s'),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0A9830),
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.65,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.location_on, // ไอคอน address
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2),
                Text(
                  'Mahasarakham University',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
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
                            onPressed: () {
                              // ใส่การทำงานของปุ่มที่ 1 ตรงนี้
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            child: Text(
                              'รายการจัดส่งทั้งหมด ($itemCount)',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.push('/send/finduser'); // ใช้เส้นทางที่ถูกต้อง
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
                                    style: TextStyle(color: Colors.white,  fontSize: 14)),
                              ],
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: incrementItemCount,
        child: Icon(Icons.add),
        backgroundColor: mainColor,
      ),
    );
  }
}