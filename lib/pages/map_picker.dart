import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class MapPicker extends StatefulWidget {
  final Position? initialPosition;

  const MapPicker({Key? key, this.initialPosition}) : super(key: key);

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  final MapController _mapController = MapController();
  LatLng? _selectedPosition;
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _selectedPosition = LatLng(
        widget.initialPosition!.latitude,
        widget.initialPosition!.longitude,
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    // ตรวจสอบสิทธิ์
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง')),
        );
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถเข้าถึงตำแหน่งได้ กรุณาอนุญาตในการตั้งค่า')),
      );
      return;
    }

    // ตรวจสอบว่า GPS เปิดอยู่
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเปิดบริการระบุตำแหน่ง')),
      );
      return;
    }

    // ดำเนินการต่อหากได้รับอนุญาตและ GPS เปิดอยู่
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      );
      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_selectedPosition!, 15);
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('หมดเวลาในการรับตำแหน่ง กรุณาลองอีกครั้ง')),
      );
    } on LocationServiceDisabledException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บริการระบุตำแหน่งถูกปิด กรุณาเปิดใช้งาน')),
      );
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการระบุตำแหน่ง')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('เลือกตำแหน่งของคุณ', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: () {
              if (_selectedPosition != null) {
                Navigator.of(context).pop({
                  'position': _selectedPosition,
                  'address': _addressController.text,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('กรุณาเลือกตำแหน่งบนแผนที่')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _selectedPosition ?? LatLng(13.7563, 100.5018),
                zoom: 13.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedPosition = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _selectedPosition == null
                      ? []
                      : [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: _selectedPosition!,
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40.0,
                            ),
                          ),
                        ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'รายละเอียดที่อยู่',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('ระบุพิกัดปัจจุบัน'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A9830),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}