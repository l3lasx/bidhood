import 'package:bidhood/components/layouts/user.dart';
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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  late Future<Map<String, dynamic>> userProfile;

  @override
  void initState() {
    super.initState();
    userProfile = _fetchUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
    var result = await ref.read(userService).me();
    ref.read(authProvider.notifier).updateUser(result['data']['data']);
    return result;
  }

  Future<void> chooseImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var upload = await ref.watch(uploadService).uploadImage(image);
        if (upload['statusCode'] == 200) {
          var res = upload['data'];
          Map<String, dynamic> payload = {
            "avatar_picture": res['url'],
          };
          var updateAvatar = await ref.watch(userService).update(payload);
          if (updateAvatar['statusCode'] == 200) {
            debugPrint("Upload Avatar Success!");
            setState(() {
              userProfile = _fetchUserData();
            });
            ref
                .read(authProvider.notifier)
                .updateUser(updateAvatar['data']['data']);
          }
        }
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> takeAPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      var upload = await ref.watch(uploadService).uploadImage(image);
      if (upload['statusCode'] == 200) {
        var res = upload['data'];
        Map<String, dynamic> payload = {
          "avatar_picture": res['url'],
        };
        var updateAvatar = await ref.watch(userService).update(payload);
        if (updateAvatar['statusCode'] == 200) {
          debugPrint("Upload Avatar Success!");
          setState(() {
            userProfile = _fetchUserData();
          });
          ref
              .read(authProvider.notifier)
              .updateUser(updateAvatar['data']['data']);
        }
      }
    }
  }

  Future<void> saveProfile() async {
    Map<String, dynamic> payload = {
      "phone": _phoneController.text,
      "fullname": _fullNameController.text,
      "address": _addressController.text
    };
    var updateProfile = await ref.watch(userService).update(payload);
    if (updateProfile['statusCode'] == 200) {
      debugPrint("Upload Profile Success!");
      setState(() {
        userProfile = _fetchUserData();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${updateProfile['data']['message']}')),
      );
      ref.read(authProvider.notifier).updateUser(updateProfile['data']['data']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final userData = snapshot.data?['data']?['data'];
            if (userData == null) {
              return const Center(child: Text('No user data available'));
            }
            _phoneController.text = userData['phone'];
            _fullNameController.text = userData['fullname'];
            _addressController.text = userData['address'];
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 48, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: '${userData['avatar_picture']}',
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                      radius: 56,
                                      backgroundImage: imageProvider,
                                      backgroundColor: Colors.white,
                                    ),
                                    placeholder: (context, url) =>
                                        const CircleAvatar(
                                      radius: 56,
                                      backgroundColor: Colors.white,
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const CircleAvatar(
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
                                              const Color(0xFF0A9830),
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
                                          takeAPhoto();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF0A9830),
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
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'เบอร์โทร',
                                    border: const OutlineInputBorder(),
                                    enabledBorder: const OutlineInputBorder(
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
                                    enabledBorder: const OutlineInputBorder(
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
                                  width: double
                                      .infinity, // ทำให้ปุ่มยืดเต็มความกว้าง
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // ใส่การทำงานของปุ่มที่ 2 ตรงนี้
                                      saveProfile();
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
                                      ref.watch(authProvider.notifier).logout();
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
                                        debugPrint(
                                            'Current location: ${position.latitude}, ${position.longitude}');
                                        // You can add more logic here, like updating the address field
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Location: ${position.latitude}, ${position.longitude}')),
                                        );
                                      } catch (e) {
                                        debugPrint(
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
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
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
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        });
  }
}
