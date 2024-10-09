import 'package:bidhood/providers/auth.dart';
import 'package:bidhood/services/user.dart';
import 'package:bidhood/services/upload.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final Color mainColor = const Color(0xFF0A9830);
  final String userName = "John Doe"; // สมมติชื่อผู้ใช้

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    return await ref.read(userService).me();
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> chooseImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var upload = ref.watch(uploadService).uploadImage(image);
        debugPrint('$upload');
      }
    } catch (e) {
      debugPrint("$e");
    }
  }
  

  Future<void> saveProfile() async {

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
        body: FutureBuilder<Map<String, dynamic>>(
            future: _fetchUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final userData = snapshot.data!['data']!['data'];
                return Stack(
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
                        child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 48, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: const Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: "${userData['avatar_picture']}",
                                          imageBuilder: (context, imageProvider) => CircleAvatar(
                                            radius: 56,
                                            backgroundImage: imageProvider,
                                            backgroundColor: Colors.white,
                                          ),
                                          placeholder: (context, url) => const CircleAvatar(
                                            radius: 56,
                                            backgroundColor: Colors.white,
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) => const CircleAvatar(
                                            radius: 56,
                                            backgroundColor: Colors.white,
                                            child: Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                // ใส่การทำงานของปุ่มที่ 1 ตรงนี้
                                                chooseImage();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xFF0A9830),
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                              ),
                                              icon: const Icon(
                                                  Icons.photo_library),
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
                                                backgroundColor:
                                                    Color(0xFF0A9830),
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                              ),
                                              icon:
                                                  const Icon(Icons.camera_alt),
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
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: mainColor, width: 2.0),
                                          ),
                                          floatingLabelStyle:
                                              TextStyle(color: mainColor),
                                        ),
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
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
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: mainColor, width: 2.0),
                                          ),
                                          floatingLabelStyle:
                                              TextStyle(color: mainColor),
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
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: mainColor, width: 2.0),
                                          ),
                                          floatingLabelStyle:
                                              TextStyle(color: mainColor),
                                        ),
                                        maxLines:
                                            3, // เพิ่มความสูงของ field ที่อยู่
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'กรุณากรอกที่อยู่';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double
                                            .infinity, // ทำให้ปุ่มยืดเต็มความกว้าง
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
                                      const SizedBox(height: 80),
                                      SizedBox(
                                        width: double
                                            .infinity, // ทำให้ปุ่มยืดเต็มความกว้าง
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            // ใส่การทำงานของปุ่มที่ 2 ตรงนี้
                                            context.go('/login');
                                            ref
                                                .watch(authProvider.notifier)
                                                .logout();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                          ),
                                          icon: const Icon(Icons.logout),
                                          label: const Text(
                                            'ออกจากระบบ',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            try {
                                              Position position =
                                                  await _determinePosition();
                                              print(
                                                  'Current location: ${position.latitude}, ${position.longitude}');
                                              // You can add more logic here, like updating the address field
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Location: ${position.latitude}, ${position.longitude}')),
                                              );
                                            } catch (e) {
                                              print(
                                                  'Error getting location: $e');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Error getting location: $e')),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: mainColor,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                          ),
                                          icon: const Icon(Icons.location_on),
                                          label: const Text(
                                            'รับตำแหน่งปัจจุบัน',
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
                );
              } else {
                return Center(child: Text('No data available'));
              }
            }));
  }
}
