import 'package:bidhood/components/cards/usercard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FindUserPage extends StatefulWidget {
  const FindUserPage({super.key});

  @override
  State<FindUserPage> createState() => _FindUserPageState();
}

class _FindUserPageState extends State<FindUserPage> {
  final Color mainColor = const Color(0xFF0A9830);
  final String userName = "John Doe"; // สมมติชื่อผู้ใช้

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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'ค้นหา...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 16),
                                    ),
                                    onChanged: (value) {
                                      // ใส่โค้ดสำหรับการค้นหาตรงนี้
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // ใส่การทำงานของปุ่มที่ 2 ตรงนี้
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                  ),
                                  label: const Text(
                                    'ค้นหา',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  icon: const Icon(Icons.search),
                                ),
                              ],
                            ),
                            const UserCard(
                              imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s',
                              fullName: 'สมชาย ใจดี',
                              address:
                                  '123 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110',
                              phoneNumber: '02-123-4567',
                            ),
                            const UserCard(
                              imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s',
                              fullName: 'สมชาย ใจดี',
                              address:
                                  '123 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110',
                              phoneNumber: '02-123-4567',
                            ),
                            const UserCard(
                              imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s',
                              fullName: 'สมชาย ใจดี',
                              address:
                                  '123 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110',
                              phoneNumber: '02-123-4567',
                            ),
                            const UserCard(
                              imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s',
                              fullName: 'สมชาย ใจดี',
                              address:
                                  '123 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110',
                              phoneNumber: '02-123-4567',
                            ),
                            const UserCard(
                              imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s',
                              fullName: 'สมชาย ใจดี',
                              address:
                                  '123 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110',
                              phoneNumber: '02-123-4567',
                            ),
                            const UserCard(
                              imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s',
                              fullName: 'สมชาย ใจดี',
                              address:
                                  '123 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110',
                              phoneNumber: '02-123-4567',
                            ),
                            const UserCard(
                              imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s',
                              fullName: 'สมชาย ใจดี',
                              address:
                                  '123 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110',
                              phoneNumber: '02-123-4567',
                            ),
                            const UserCard(
                              imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s',
                              fullName: 'สมชาย ใจดี',
                              address:
                                  '123 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110',
                              phoneNumber: '02-123-4567',
                            ),
                            const UserCard(
                              imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s',
                              fullName: 'สมชาย ใจดี',
                              address:
                                  '123 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110',
                              phoneNumber: '02-123-4567',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
