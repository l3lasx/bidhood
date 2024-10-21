import 'dart:io';

import 'package:bidhood/environments/app_config.dart';
import 'package:bidhood/models/user/user_body_for_create.dart';
import 'package:bidhood/providers/auth.dart';
import 'package:bidhood/pages/map_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

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
  String? avatarPicture;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  Position? _currentPosition;

  XFile? _image;

  void _openMap() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapPicker(
          initialPosition: _currentPosition,
          initialAddress: _addressController.text,
        ),
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
        _latitudeController.text = _currentPosition!.latitude.toString();
        _longitudeController.text = _currentPosition!.longitude.toString();
      });
    }
  }

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอก$fieldName';
    }
    return null;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _licensePlateController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> uploadPublicImage(XFile imageFile) async {
    try {
      final dio = Dio();
      final api = config['endpoint_1'] + '/public/upload';
      String fileName = imageFile.name;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      var response = await dio.post(
        api,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      debugPrint('${response.data}');
      return {
        "statusCode": response.statusCode,
        "data": response.data,
      };
    } catch (e) {
      debugPrint("$e");
      if (e is DioException) {
        return {
          "statusCode": e.response?.statusCode,
          "data": e.response?.data,
          "error": e.message,
        };
      }
      return {
        "statusCode": 500,
        "error": "An unexpected error occurred",
      };
    }
  }

  Future<String> uploadAvatar() async {
    var defaultPic =
        "https://www.gravatar.com/avatar/3b3be63a4c2a439b013787725dfce802?d=identicon";
    if (_image != null) {
      var upload = await uploadPublicImage(_image!);
      if (upload['statusCode'] == 200) {
        var res = upload['data'];
        return res['url'];
      }
      return defaultPic;
    }
    return defaultPic;
  }

  Future<void> chooseImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = image;
        });
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> takeAPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Widget buildAvatarWithPath(XFile? xFile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (xFile != null)
          CircleAvatar(
            radius: 56,
            backgroundColor: Colors.white,
            child: _image != null
                ? ClipOval(
                    child: Image.file(
                      File(xFile.path),
                      width: 112,
                      height: 112,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, color: Colors.red),
                    ),
                  )
                : const Text("กรุณาเลือกรูป"),
          )
        else
          CachedNetworkImage(
            imageUrl:
                'https://www.gravatar.com/avatar/3b3be63a4c2a439b013787725dfce802?d=identicon',
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
            errorWidget: (context, url, error) => CircleAvatar(
              radius: 56,
              backgroundColor: Colors.white,
              child: _buildErrorIcon(),
            ),
          ),
        const SizedBox(height: 10),
        Text(
          xFile != null ? '' : 'No file selected',
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorIcon() {
    return const Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 56,
          backgroundColor: Colors.white,
        ),
        Icon(Icons.error, color: Colors.red),
      ],
    );
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
                                  'ข่อมูลของคุณจะถูกเก็บเป็นความลับ',
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
                                    buildAvatarWithPath(_image),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                            ),
                                            icon:
                                                const Icon(Icons.photo_library),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
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
                                        String? baseValidation =
                                            _validateField(value, 'เบอร์โทร');
                                        if (baseValidation != null)
                                          return baseValidation;
                                        if (value!.length != 10) {
                                          return 'เบอร์โทรต้องมี 10 หลัก';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _usernameController,
                                      decoration: InputDecoration(
                                        labelText: 'ชื่อผู้ใช้',
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
                                      validator: (value) =>
                                          _validateField(value, 'ชื่อผู้ใช้'),
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
                                        String? baseValidation =
                                            _validateField(value, 'รหัสผ่าน');
                                        if (baseValidation != null)
                                          return baseValidation;
                                        if (value!.trim().length < 6) {
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
                                        String? baseValidation = _validateField(
                                            value, 'ยืนยันรหัสผ่าน');
                                        if (baseValidation != null)
                                          return baseValidation;
                                        if (value!.trim() !=
                                            _passwordController.text.trim()) {
                                          return 'รหัสผ่านไม่ตรงกัน';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    if (_selectedUserType == 'User') ...[
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
                                        validator: (value) =>
                                            _validateField(value, 'ที่อยู่'),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _latitudeController,
                                              decoration: InputDecoration(
                                                labelText: 'ละติจูด',
                                                border:
                                                    const OutlineInputBorder(),
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: mainColor,
                                                      width: 2.0),
                                                ),
                                                floatingLabelStyle:
                                                    TextStyle(color: mainColor),
                                                fillColor: Colors.grey[200],
                                                filled: true,
                                              ),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              readOnly: true,
                                              enabled: false,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _longitudeController,
                                              decoration: InputDecoration(
                                                labelText: 'ลองจิจูด',
                                                border:
                                                    const OutlineInputBorder(),
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: mainColor,
                                                      width: 2.0),
                                                ),
                                                floatingLabelStyle:
                                                    TextStyle(color: mainColor),
                                                fillColor: Colors.grey[200],
                                                filled: true,
                                              ),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              readOnly: true,
                                              enabled: false,
                                            ),
                                          ),
                                        ],
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
                                    ],
                                    if (_selectedUserType == 'Rider') ...[
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _licensePlateController,
                                        decoration: InputDecoration(
                                          labelText: 'ป้ายทะเบียน',
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
                                        validator: (value) => _validateField(
                                            value, 'ป้ายทะเบียน'),
                                      ),
                                    ],
                                  ],
                                ),
                              ] else if (_currentStep == 2) ...[
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/registration_success.png',
                                        width: 200,
                                        height: 200,
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'การสมัครเสร็จสมบูรณ์',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'ขอบคุณที่สมัครเป็นสมาชิกกับเรา',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
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
                                            if (_selectedUserType == 'User' &&
                                                _currentPosition == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'กรุณารับตำแหน่งปัจจุบัน'),
                                                ),
                                              );
                                            } else {
                                              if (_confirmPasswordController
                                                      .text
                                                      .trim() !=
                                                  _passwordController.text
                                                      .trim()) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'รหัสผ่านของคุณไม่เหมือนกัน'),
                                                  ),
                                                );
                                                return;
                                              }

                                              // Set address to empty if the user type is Rider
                                              if (_selectedUserType ==
                                                  'Rider') {
                                                _addressController.text = '-';
                                              }

                                              var avatarPic =
                                                  await uploadAvatar();

                                              UserBodyForCreate userBody = UserBodyForCreate(
                                                  phone: _phoneController.text
                                                      .trim(),
                                                  password:
                                                      _passwordController
                                                          .text
                                                          .trim(),
                                                  fullname:
                                                      _usernameController
                                                          .text
                                                          .trim(),
                                                  role: _selectedUserType,
                                                  address: _addressController
                                                      .text
                                                      .trim(),
                                                  location: _selectedUserType ==
                                                          'User'
                                                      ? Location(
                                                          lat: _currentPosition!
                                                              .latitude,
                                                          long:
                                                              _currentPosition!
                                                                  .longitude)
                                                      : null,
                                                  carPlate: _selectedUserType ==
                                                          'Rider'
                                                      ? _licensePlateController
                                                          .text
                                                          .trim()
                                                      : '',
                                                  avatarPicture: avatarPic);
                                              var response = await ref
                                                  .read(authProvider.notifier)
                                                  .register(userBody);
                                              if (response['statusCode'] !=
                                                  201) {
                                                debugPrint(
                                                    '${response['data']}');
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
