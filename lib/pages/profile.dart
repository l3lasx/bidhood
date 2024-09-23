import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color mainColor = const Color(0xFF0A9830);
  final String userName = "John Doe"; // สมมติชื่อผู้ใช้

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

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
                context.push('/profile'); // สมมติว่ามีหน้าโปรไฟล์
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
                            horizontal: 48, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 56,
                              backgroundImage: NetworkImage(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s'),
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // ใส่การทำงานของปุ่มที่ 1 ตรงนี้
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF0A9830),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                    ),
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text(
                                      'เลือกรูป',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // ใส่การทำงานของปุ่มที่ 2 ตรงนี้
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF0A9830),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                    ),
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text(
                                      'ถ่ายรูป',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'เบอร์โทร',
                                border: const OutlineInputBorder(),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: mainColor, width: 2.0),
                                ),
                                floatingLabelStyle: TextStyle(color: mainColor),
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกเบอร์โทร';
                                }
                                if (value.length != 10) {
                                  return 'เบอร์โทรต้องมี 10 หลัก';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                labelText: 'ชื่อ-นามสกุล',
                                border: const OutlineInputBorder(),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: mainColor, width: 2.0),
                                ),
                                floatingLabelStyle: TextStyle(color: mainColor),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกชื่อ-นามสกุล';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                labelText: 'ที่อยู่',
                                border: const OutlineInputBorder(),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: mainColor, width: 2.0),
                                ),
                                floatingLabelStyle: TextStyle(color: mainColor),
                              ),
                              maxLines: 3, // เพิ่มความสูงของ field ที่อยู่
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกที่อยู่';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity, // ทำให้ปุ่มยืดเต็มความกว้าง
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // ใส่การทำงานของปุ่มที่ 2 ตรงนี้
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                icon: const Icon(Icons.save),
                                label: const Text(
                                  'บันทึกข้อมูล',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
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