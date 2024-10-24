// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class AddItemBottomSheet extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onItemAdded;

  const AddItemBottomSheet({super.key, required this.onItemAdded});

  @override
  ConsumerState<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends ConsumerState<AddItemBottomSheet> {
  final Color mainColor = const Color(0xFF0A9830);
  XFile? _image;
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    setState(() {
      _image = image;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8, // Fixed height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'สินค้าของคุณ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library, color: Colors.white),
                          label: const Text('เลือกรูป', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          label: const Text('ถ่ายรูป', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: _image != null
                          ? Center(
                              child: Image.file(
                                File(_image!.path),
                                fit: BoxFit.contain,
                              ),
                            )
                          : const Center(
                              child: Text(
                                'กรุณาเลือกรูปภาพ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _detailsController,
                      decoration: const InputDecoration(
                        labelText: 'รายละเอียด',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    /*TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'จำนวน',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    )*/
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_image == null ||
                            _detailsController.text.isEmpty ||
                            _quantityController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('กรุณากรอกข้อมูลให้ครบทุกช่อง'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          final newItem = {
                            'image': _image,
                            'details': _detailsController.text,
                            'quantity': int.parse(_quantityController.text),
                          };
                          widget.onItemAdded(newItem);
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('เพิ่ม', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
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