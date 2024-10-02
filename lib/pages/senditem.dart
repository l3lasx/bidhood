import 'dart:io';

import 'package:bidhood/components/cards/usercard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class SendItemPage extends StatefulWidget {
  const SendItemPage({super.key});

  @override
  State<SendItemPage> createState() => _SendItemPageState();
}

class _SendItemPageState extends State<SendItemPage> {
  final Color mainColor = const Color(0xFF0A9830);
  final String userName = "John Doe"; // Placeholder user name
  int _currentStep = 0;
  int itemCount = 0; // Number of items
  XFile? _image; // Variable to store the selected image
  final TextEditingController _detailsController =
      TextEditingController(); // Controller for the details text field
  final TextEditingController _quantityController =
      TextEditingController(text: '1'); // Controller for the quantity field
  List<Map<String, dynamic>> _items = []; // List to store added items

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    setState(() {
      _image = image;
    });
  }

  void _showAddItemDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: const Text(
                          'สินค้าของคุณ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library,
                                color: Colors.white),
                            label: const Text('เลือกรูป',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.white),
                            label: const Text('ถ่ายรูป',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_image != null)
                        Center(
                          child: Image.file(
                            File(_image!.path),
                            height: 200,
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _detailsController,
                        decoration: const InputDecoration(
                          labelText: 'รายละเอียด',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'จำนวน',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_image == null ||
                                _detailsController.text.isEmpty ||
                                _quantityController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'กรุณากรอกข้อมูลให้ครบทุกช่อง'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              final newItem = {
                                'image': _image,
                                'details': _detailsController.text,
                                'quantity': int.parse(_quantityController.text),
                              };
                              setState(() {
                                _items.add(newItem);
                                itemCount++;
                                _image = null;
                                _detailsController.clear();
                                _quantityController.text = '1';
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('เพิ่มรายการสำเร็จ'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Update the parent widget's state
                              this.setState(() {});
                            }
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('เพิ่ม',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
                context.go('/profile');
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
                  Icons.location_on,
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "ข้อมูลการจัดส่ง",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const UserCard(
                        imageUrl:
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2UOW09a8y-Ue_FtTFn01C4U4-dZmIax-P_g&s',
                        fullName: 'สมชาย ใจดี',
                        address:
                            '123 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110',
                        phoneNumber: '02-123-4567',
                      ),
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
                                      backgroundColor: _currentStep == index
                                          ? Colors.green
                                          : Colors.grey,
                                      child: Icon(
                                        [
                                          Icons.list,
                                          Icons.photo_camera,
                                          Icons.check_circle
                                        ][index],
                                        color: Colors.white,
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
                                    'รายการส่ง',
                                    'ข้อมูลการจัดส่ง',
                                    'ยืนยันการจัดส่ง'
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
                        Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'รายการส่ง ($itemCount)',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: _showAddItemDrawer,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF0A9876),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add, color: Colors.white),
                                          SizedBox(width: 2),
                                          Text('เพิ่มรายการ',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Column(
                                  children: _items.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (item['image'] != null)
                                            Image.file(
                                              File(item['image'].path),
                                              width: 50,
                                              height: 50,
                                            ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: Text(item['details']),
                                            ),
                                          ),
                                          Text('จำนวน: ${item['quantity']}'),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else if (_currentStep == 1) ...[
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt,
                                    color: Colors.white),
                                label: const Text('ถ่ายรูป',
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mainColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_image != null)
                                Image.file(
                                  File(_image!.path),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              else
                                Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Text('ไม่มีรูปภาพ'),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Text(
                                'หมายเหตุ: คุณต้องถ่ายรูปเพื่อดำเนินการต่อ',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ] else if (_currentStep == 2) ...[
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'สรุปรายการส่ง:',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                children: _items.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (item['image'] != null)
                                          Image.file(
                                            File(item['image'].path),
                                            width: 50,
                                            height: 50,
                                          ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Text(item['details']),
                                          ),
                                        ),
                                        Text('จำนวน: ${item['quantity']}'),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: _currentStep == 2 ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentStep < 2) ...[
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
                              GestureDetector(
                                onTap: (_currentStep == 0 && _items.isEmpty) || (_currentStep == 1 && _image == null)
                                    ? () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(_currentStep == 0 
                                                ? 'กรุณาเพิ่มอย่างน้อย 1 รายการก่อนดำเนินการต่อ'
                                                : 'กรุณาถ่ายรูปก่อนดำเนินการต่อ'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    : null,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: (_currentStep == 0 && _items.isEmpty) || (_currentStep == 1 && _image == null)
                                      ? null
                                      : () {
                                          setState(() {
                                            _currentStep += 1;
                                          });
                                        },
                                  child: const Text(
                                    'ถัดไป',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ] else ...[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  context.go('/send');
                                },
                                child: const Text(
                                  'ตกลง',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
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