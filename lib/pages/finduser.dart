import 'package:bidhood/components/cards/usercard.dart';
import 'package:bidhood/components/layouts/user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FindUserPage extends StatefulWidget {
  const FindUserPage({super.key});

  @override
  State<FindUserPage> createState() => _FindUserPageState();
}
class _FindUserPageState extends State<FindUserPage> {
  final Color mainColor = const Color(0xFF0A9830);
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return UserLayout(
      bodyWidget: Positioned(
        top: 50,
        left: 0,
        right: 0,
        bottom: 0,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'ค้นหาผู้ใช้',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Implement search functionality here
                          debugPrint('Searching for: ${_searchController.text}');
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: EdgeInsets.all(16),
                          backgroundColor: mainColor,
                        ),
                        child: const Icon(Icons.search, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height: 20), // Add some space between search and list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 10, // หรือจำนวน UserCard ที่คุณต้องการแสดง
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // เมื่อ UserCard ถูกแตะ, นำทางไปยัง SendItemPage
                          context.go('/send/finduser/senditem');
                        },
                        child: const UserCard(
                          imageUrl:
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s',
                          fullName: 'สมชาย ใจดี',
                          address:
                              '123 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110',
                          phoneNumber: '02-123-4567',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
