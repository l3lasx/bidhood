import 'package:bidhood/components/cards/usercard.dart';
import 'package:bidhood/components/layouts/user.dart';
import 'package:bidhood/providers/auth.dart';
import 'package:bidhood/services/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FindUserPage extends ConsumerStatefulWidget {
  const FindUserPage({super.key});

  @override
  ConsumerState<FindUserPage> createState() => _FindUserPageState();
}

class _FindUserPageState extends ConsumerState<FindUserPage> {
  final Color mainColor = const Color(0xFF0A9830);
  final TextEditingController _searchController = TextEditingController();
  late Future<Map<String, dynamic>> userListData;
  List<dynamic> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    userListData = _fetchAllUser();
    var phone = ref.read(authProvider).userData['phone'];
    userListData.then((data) {
      setState(() {
        filteredUsers = data['data']['data'].where((user) {
          return (user['role'] != 'Rider' && user['phone'] != phone);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchAllUser() async {
    return await ref.read(userService).users();
  }

  void _filterUsers(String query) {
    var phone = ref.read(authProvider).userData['phone'];
    userListData.then((data) {
      setState(() {
        filteredUsers = data['data']['data'].where((user) {
          if (user['role'] != 'Rider' && user['phone'] != phone) {
            return true;
          }
          if (query.isEmpty) {
            return true; // แสดงทุกคนถ้าไม่มีการค้นหา
          } else {
            final fullname = user['fullname']?.toLowerCase() ?? '';
            final phoneNumber = user['phone']?.toLowerCase() ?? '';
            final lowercaseQuery = query.toLowerCase();
            return fullname.contains(lowercaseQuery) ||
                phoneNumber.contains(lowercaseQuery);
          }
        }).toList();
      });
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
                          onChanged: _filterUsers,
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
                        onPressed: () => _filterUsers(_searchController.text),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                          backgroundColor: mainColor,
                        ),
                        child: const Icon(Icons.search, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<Map<String, dynamic>>(
                    future: userListData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        if (filteredUsers.isEmpty) {
                          return const Center(
                              child: Text('ไม่พบผู้ใช้งานระบบ'));
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return GestureDetector(
                              onTap: () {
                                context.go('/send/finduser/senditem',
                                    extra: user);
                              },
                              child: UserCard(
                                imageUrl: user['avatar_picture'] ??
                                    'https://via.placeholder.com/150',
                                fullName: user['fullname'] ?? 'Unknown Name',
                                address:
                                    user['address'] ?? 'No address provided',
                                phoneNumber: user['phone'] ?? 'No phone number',
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: Text('ไม่พบผู้ใช้งานระบบ'));
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
