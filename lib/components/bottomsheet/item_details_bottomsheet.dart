// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ItemDetailsDrawer extends StatefulWidget {
  final String orderId;
  final String sender;
  final String receiver;
  final String receiverAddress;
  final List<String> itemImages;
  final int deliveryStatus;
  final List<String> des;
  final String? rider;
  final DateTime deliveryDate;
  final DateTime? completionDate;
  final LatLng senderLocation;
  final LatLng receiverLocation;
  final String userRole;
  final transactionID;
  // final LatLng riderLocation;
  final Function()? onAcceptJob;
  const ItemDetailsDrawer(
      {super.key,
      required this.orderId,
      required this.sender,
      required this.receiver,
      required this.receiverAddress,
      required this.itemImages,
      required this.des,
      required this.deliveryStatus,
      required this.rider,
      required this.deliveryDate,
      this.completionDate,
      required this.senderLocation,
      required this.receiverLocation,
      // required this.riderLocation,
      required this.userRole,
      required this.transactionID,
      this.onAcceptJob});

  @override
  // ignore: library_private_types_in_public_api
  _ItemDetailsDrawerState createState() => _ItemDetailsDrawerState();
}

class _ItemDetailsDrawerState extends State<ItemDetailsDrawer> {
  List<LatLng> _routePoints = [];
  double _distance = 0.0;
  bool _isLoading = true;
  final List<String> _steps = [
    '',
    'รอไรเดอร์มารับสินค้า',
    'ไรเดอร์รับงาน',
    'ไรเดอร์เข้ารับพัสดุ',
    'รับสินค้าแล้วกำลังเดินทาง',
    'นำส่งสินค้าแล้ว',
  ];
  @override
  void initState() {
    super.initState();
    _fetchRouteAndDistance();
  }

  Future<void> _fetchRouteAndDistance() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/${widget.senderLocation.longitude},${widget.senderLocation.latitude};${widget.receiverLocation.longitude},${widget.receiverLocation.latitude}?overview=full&geometries=geojson'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
      final distance = data['routes'][0]['distance'] as num;

      setState(() {
        _routePoints = coordinates
            .map((coord) => LatLng(coord[1] as double, coord[0] as double))
            .toList();
        _distance = distance / 1000;
        _isLoading = false;
      });
    } else {
      debugPrint('Failed to fetch route and distance');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void goToRealtime() {
    context.go('/realtime', extra: {
      'transactionID': widget.transactionID,
      'orderID': widget.orderId
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
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
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'รายละเอียดการจัดส่ง',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Order ID', widget.orderId),
              _buildInfoRow('ผู้ส่ง', widget.sender),
              _buildInfoRow('ผู้รับ', widget.receiver),
              _buildInfoRow('ที่อยู่ผู้รับ', widget.receiverAddress),
              _buildInfoRow('สถานะการจัดส่ง', _steps[widget.deliveryStatus]),
              if (widget.rider != null && widget.rider!.isNotEmpty) ...[
                _buildInfoRow('ผู้จัดส่ง', widget.rider ?? ''),
                _buildInfoRow(
                    'วันที่จัดส่ง', widget.deliveryDate.toLocal().toString()),
                if (widget.completionDate != null)
                  _buildInfoRow('วันที่จัดส่งเสร็จสิ้น',
                      widget.completionDate!.toLocal().toString()),
              ],
              const SizedBox(height: 20),
              const Text(
                'รายการสินค้า',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.itemImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        // รูปภาพสินค้า
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: widget.itemImages[index],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // รายละเอียดสินค้า
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.des[index],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        // จำนวนสินค้า
                        const Text(
                          '1', // ตัวอย่างจำนวน, ควรใช้ข้อมูลจริงจาก API
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'แผนที่',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FlutterMap(
                    options: MapOptions(
                      center: LatLng(
                        (widget.senderLocation.latitude +
                                widget.receiverLocation.latitude) /
                            2,
                        (widget.senderLocation.longitude +
                                widget.receiverLocation.longitude) /
                            2,
                      ),
                      zoom: 12.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: widget.senderLocation,
                            builder: (ctx) => const Icon(Icons.location_on,
                                color: Colors.blue),
                          ),
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: widget.receiverLocation,
                            builder: (ctx) => const Icon(Icons.location_on,
                                color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : _buildInfoRow(
                      'ระยะทาง', '${_distance.toStringAsFixed(2)} กิโลเมตร'),
              if (widget.userRole == 'Rider')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.onAcceptJob != null) {
                        widget.onAcceptJob!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'รับงาน',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              if (widget.userRole != 'Rider' && widget.deliveryStatus >= 2)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      goToRealtime();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'ดูข้อมูลเรียวไทม์',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
