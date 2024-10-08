import 'package:bidhood/models/user/user_body_for_create.dart';
import 'package:bidhood/providers/auth.dart';
import 'package:bidhood/pages/map_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final Color mainColor = const Color(0xFF0A9830);
  int _currentStep = 0;
  String? _selectedUserType;
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();

  Position? _currentPosition;

  void _openMap() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapPicker(initialPosition: _currentPosition),
      ),
    );

    if (result != null) {
      setState(() {
        _currentPosition = Position(
          latitude: result['position'].latitude,
          longitude: result['position'].longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        _addressController.text = result['address'];
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB8E986), Colors.white],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.65,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0A9830),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.shopping_basket,
                          color: Colors.white,
                          size: 40,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'BidHood',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ส่งอาหารเร็วทันใจไว้ใจเรา',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'สมัครสมาชิก',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Divider(
                                color: Colors.black,
                                thickness: 5,
                                height: 1,
                                endIndent: 245,
                              ),
                              if (_currentStep == 0) ...[
                                const Text(
                                  'ประเภทสมาชิก',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'คุณต้องการเป็นสมาชิกแบบใด ?',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ] else if (_currentStep == 1) ...[
                                const Text(
                                  'กรอกข้อมูลที่จำเป็น',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'ข่อมูลของคุณจะถูกเก็บเป็นความลับ ?',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ] else if (_currentStep == 2) ...[
                                const Text(
                                  'ขอบคุณสำหรับการสมัรสมาชิก',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'อาหารแสนอร่อยรอคุณอยู่...',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                children: List.generate(3, (index) {
                                  return Expanded(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            if (index > 0)
                                              Expanded(
                                                child: Divider(
                                                  color: _currentStep >= index
                                                      ? Colors.green
                                                      : Colors.grey,
                                                  thickness: 2,
                                                ),
                                              ),
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor:
                                                  _currentStep == index
                                                      ? Colors.green
                                                      : Colors.grey,
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            if (index < 2)
                                              Expanded(
                                                child: Divider(
                                                  color: _currentStep > index
                                                      ? Colors.green
                                                      : Colors.grey,
                                                  thickness: 2,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          [
                                            'ประเภท',
                                            'กรอกข้อมูล',
                                            'เสร็จสิ้น'
                                          ][index],
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 16),
                              if (_currentStep == 0) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedUserType = 'Rider';
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.motorcycle,
                                            color: _selectedUserType == 'Rider'
                                                ? Colors.green
                                                : Colors.grey,
                                            size: 40,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text('ไรเดอร์'),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedUserType = 'User';
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: _selectedUserType == 'User'
                                                ? Colors.green
                                                : Colors.grey,
                                            size: 40,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text('ลูกค้า'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ] else if (_currentStep == 1) ...[
                                Column(
                                  children: [
                                    TextFormField(
                                      controller: _phoneController,
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
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                        labelText: 'รหัสผ่าน',
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
                                        suffixIcon: _passwordController
                                                .text.isNotEmpty
                                            ? IconButton(
                                                icon: Icon(
                                                  _isPasswordVisible
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _isPasswordVisible =
                                                        !_isPasswordVisible;
                                                  });
                                                },
                                              )
                                            : null,
                                      ),
                                      obscureText: !_isPasswordVisible,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'กรุณากรอกรหัสผ่าน';
                                        }
                                        if (value.length < 6) {
                                          return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      decoration: InputDecoration(
                                        labelText: 'ยืนยันรหัสผ่าน',
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
                                        suffixIcon: _confirmPasswordController
                                                .text.isNotEmpty
                                            ? IconButton(
                                                icon: Icon(
                                                  _isPasswordVisible
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _isPasswordVisible =
                                                        !_isPasswordVisible;
                                                  });
                                                },
                                              )
                                            : null,
                                      ),
                                      obscureText: !_isPasswordVisible,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'กรุณายืนยันรหัสผ่าน';
                                        }
                                        if (value != _passwordController.text) {
                                          return 'รหัสผ่านไม่ตรงกัน';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        setState(() {});
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
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'กรุณากรอกที่อยู่';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    if (_selectedUserType == 'Rider')
                                      TextFormField(
                                        controller: _licensePlateController,
                                        decoration: const InputDecoration(
                                          labelText: 'ป้ายทะเบียน',
                                          border: OutlineInputBorder(),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.green,
                                                width: 2.0),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'กรุณากรอกป้ายทะเบียน';
                                          }
                                          return null;
                                        },
                                      ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: _openMap,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: mainColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                      icon: const Icon(Icons.location_on),
                                      label: const Text(
                                        'เลือกตำแหน่งปัจจุบัน',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    if (_currentPosition != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'ตำแหน่งปัจจุบัน: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                  ],
                                ),
                              ] else if (_currentStep == 2) ...[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ประเภทสมาชิก: $_selectedUserType'),
                                    const SizedBox(height: 8),
                                    Text('เบอร์โทร: ${_phoneController.text}'),
                                    const SizedBox(height: 8),
                                    Text(
                                        'ชื่อ-นามสกุล: ${_fullNameController.text}'),
                                    const SizedBox(height: 8),
                                    Text('ที่อยู่: ${_addressController.text}'),
                                    if (_selectedUserType == 'Rider') ...[
                                      const SizedBox(height: 8),
                                      Text(
                                          'ป้ายทะเบียน: ${_licensePlateController.text}'),
                                    ],
                                    if (_currentPosition != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'ตำแหน่ง: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    const Text('การสมัครเสร็จสมบูรณ์'),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),
                              if (_currentStep < 2) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: _currentStep > 0
                                          ? () {
                                              setState(() {
                                                _currentStep -= 1;
                                              });
                                            }
                                          : null,
                                      child: const Text(
                                        'ย้อนกลับ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (_currentStep == 0 &&
                                            _selectedUserType == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'กรุณาเลือกประเภทผู้ใช้')),
                                          );
                                        } else if (_currentStep == 1) {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            if (_currentPosition == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'กรุณารับตำแหน่งปัจจุบัน'),
                                                ),
                                              );
                                            } else {
                                              if (_confirmPasswordController
                                                      .text !=
                                                  _passwordController.text) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'รหัสผ่านของคุณไม่เหมือนกัน'),
                                                  ),
                                                );
                                              }

                                              UserBodyForCreate userBody =
                                                  UserBodyForCreate(
                                                      phone:
                                                          _phoneController.text,
                                                      password:
                                                          _passwordController
                                                              .text,
                                                      fullname:
                                                          _fullNameController
                                                              .text,
                                                      role: _selectedUserType,
                                                      address:
                                                          _addressController
                                                              .text,
                                                      location: Location(
                                                          lat: _currentPosition!
                                                              .latitude,
                                                          long:
                                                              _currentPosition!
                                                                  .longitude),
                                                      carPlate:
                                                          _licensePlateController
                                                              .text);
                                              var response = await ref
                                                  .read(authProvider.notifier)
                                                  .register(userBody);
                                              if (response['statusCode'] !=
                                                  201) {
                                                    debugPrint('${response['data']}');
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "สมัครสมาชิกไม่สำเร็จ ( Status ${response['statusCode']} ) ${response['data']['message']} "),
                                                  ),
                                                );
                                                return;
                                              }
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'ยินดีด้วยสมัครสมาชิกเรียบร้อย'),
                                                ),
                                              );
                                              setState(() {
                                                _currentStep += 1;
                                              });
                                            }
                                          }
                                        } else {
                                          setState(() {
                                            _currentStep += 1;
                                          });
                                        }
                                      },
                                      child: Text(
                                        _currentStep == 1
                                            ? 'สมัครสมาชิก'
                                            : 'ถัดไป',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      // TODO: Implement login logic
                                      context.go('/login');
                                    },
                                    child: const Text(
                                      'เข้าสู่ระบบเลย!',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              if (_currentStep <
                                  2) // แสดง Row เฉพาะใน step 0 และ 1
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        // TODO: Implement forgot password logic
                                      },
                                      child: const Text(
                                        'หากมีบัญชีอยู่แล้ว?',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.go('/login');
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.black,
                                      ),
                                      child: const Text(
                                        'เข้าสู่ระบบ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
