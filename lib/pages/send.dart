import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                              context.push('/finduser');
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
                          ? Center(
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
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        'รายการจัดส่งสินค้าที่ ${index + 1}',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text('รายละเอียดการจัดส่ง'),
                                      leading: Icon(Icons.local_shipping, color: mainColor),
                                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                                      onTap: () {
                                        // Handle item tap
                                      },
                                    ),
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