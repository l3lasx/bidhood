// ignore_for_file: unused_field
import 'dart:io';
import 'package:bidhood/components/cards/usercard.dart';
import 'package:bidhood/components/layouts/user.dart';
import 'package:bidhood/services/order.dart';
import 'package:bidhood/services/upload.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bidhood/components/bottomsheet/add_item_bottomsheet.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SendItemPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> user;

  const SendItemPage({super.key, required this.user});

  @override
  ConsumerState<SendItemPage> createState() => _SendItemPageState();
}

class _SendItemPageState extends ConsumerState<SendItemPage> {
  final Color mainColor = const Color(0xFF0A9830);
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  int _currentStep = 0;
  int itemCount = 0; // Number of items
  XFile? _image; // Variable to store the selected image
  late String statusPicture;
  final TextEditingController _detailsController =
      TextEditingController(); // Controller for the details text field
  final TextEditingController _quantityController =
      TextEditingController(text: '1'); // Controller for the quantity field
  final List<Map<String, dynamic>> _items = []; // List to store added items
  late bool isLoading = false;
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    var upload = await ref.read(uploadService).uploadImage(image!);
    if (upload['statusCode'] == 200) {
      var res = upload['data'];
      setState(() {
        _image = image;
        statusPicture = res['url'];
      });
    }
  }

  Future<void> createNewOrder() async {
    try {
      setState(() {
        isLoading = true;
      });
      Map<String, dynamic> payload = {
        "receiver_id": widget.user['user_id'],
        "product_list": _items.map((item) {
          return {
            "name": item['name'],
            "description": item['details'],
            "image": item['image'],
            "quantity": item['quantity'],
          };
        }).toList(),
        "event": {"picture": statusPicture}
      };

      var response = await ref.read(orderService).create(payload);
      if (response['statusCode'] == 200) {
        debugPrint("Created oder success");
        context.go('/send?refresh=true');
      }
    } catch (err) {
      debugPrint("Failed to create");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showAddItemDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return AddItemBottomSheet(
          onItemAdded: (Map<String, dynamic> newItem) async {
            try {
              XFile productImage = newItem['image'];
              var upload =
                  await ref.read(uploadService).uploadImage(productImage);
              if (upload['statusCode'] == 200) {
                var res = upload['data'];
                newItem['image'] = res['url'];
                if (mounted) {
                  setState(() {
                    _items.add(newItem);
                    itemCount++;
                  });
                  Navigator.pop(bottomSheetContext);
                }
              } else {
                throw Exception('Upload failed');
              }
            } catch (error) {
              debugPrint('$error');
            }
          },
        );
      },
    );
  }

  Widget _buildLocationMap() {
    final double? lat = widget.user['location']?['lat'];
    final double? long = widget.user['location']?['long'];

    if (lat == null || long == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20), // Updated to match Card's radius
        ),
        child: const Center(
          child: Text('ไม่พบข้อมูลตำแหน่ง'),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // Updated to match Card's radius
      ),
      child: ClipRRect( // Added to clip the map to the rounded corners
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(lat, long),
            zoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(lat, long),
                  width: 80,
                  height: 80,
                  builder: (context) => const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UserLayout(
      key: _scaffoldMessengerKey,
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
                  UserCard(
                    imageUrl: widget.user['avatar_picture'] ??
                        'https://via.placeholder.com/150',
                    fullName: widget.user['fullname'] ?? 'Unknown Name',
                    address: widget.user['address'] ?? 'No address provided',
                    phoneNumber: widget.user['phone'] ?? 'No phone number',
                  ),
                  const SizedBox(height: 16),
                  _buildLocationMap(),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    backgroundColor: const Color(0xFF0A9876),
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
                              children: _items.asMap().entries.map((entry) {
                                final item = entry.value; // Get the item
                                final index = entry.key; // Get the index
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (item['image'] != null)
                                        CachedNetworkImage(
                                            imageUrl: item['image'],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.grey[300],
                                                  child: const Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                ),
                                            errorWidget: (context, url,
                                                    error) =>
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.grey[300],
                                                  child:
                                                      const Icon(Icons.error),
                                                )),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(item['details']),
                                        ),
                                      ),
                                      //Text('จำนวน: ${item['quantity']}'),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _items.removeAt(
                                                index); // Use the correct index
                                            itemCount--;
                                          });
                                        },
                                      ),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_image != null)
                            Image.file(
                              File(_image!.path),
                              height: 200,
                              width: double.infinity,
                            )
                          else
                            Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Text('ไม่มีรูปภาพ'),
                              ),
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
                          const Text(
                            'สรุปรายการส่ง:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: _items.map((item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (item['image'] != null)
                                      CachedNetworkImage(
                                          imageUrl: item['image'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey[300],
                                                child: const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.error),
                                              )),
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
                      mainAxisAlignment: _currentStep == 2
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.spaceBetween,
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
                            onTap: (_currentStep == 0 && _items.isEmpty) ||
                                    (_currentStep == 1 && _image == null)
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
                              onPressed:
                                  (_currentStep == 0 && _items.isEmpty) ||
                                          (_currentStep == 1 && _image == null)
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
                          !isLoading
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    createNewOrder();
                                  },
                                  child: const Text(
                                    'ตกลง',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : const CircularProgressIndicator()
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
    );
  }
}
