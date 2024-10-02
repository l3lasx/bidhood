import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
  final String deliveryStatus;
  final String rider;
  final DateTime deliveryDate;
  final DateTime? completionDate;
  final LatLng senderLocation;
  final LatLng receiverLocation;

  const ItemDetailsDrawer({
    Key? key,
    required this.orderId,
    required this.sender,
    required this.receiver,
    required this.receiverAddress,
    required this.itemImages,
    required this.deliveryStatus,
    required this.rider,
    required this.deliveryDate,
    this.completionDate,
    required this.senderLocation,
    required this.receiverLocation,
  }) : super(key: key);

  @override
  _ItemDetailsDrawerState createState() => _ItemDetailsDrawerState();
}

class _ItemDetailsDrawerState extends State<ItemDetailsDrawer> {
  List<LatLng> _routePoints = [];
  double _distance = 0.0;
  bool _isLoading = true;

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
        _distance = distance / 1000; // Convert meters to kilometers
        _isLoading = false;
      });
    } else {
      print('Failed to fetch route and distance');
      setState(() {
        _isLoading = false;
      });
    }
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ListView(
            controller: controller,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              SizedBox(height: 20),
              Text(
                'รายละเอียดการจัดส่ง',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              _buildInfoRow('Order ID', widget.orderId),
              _buildInfoRow('ผู้ส่ง', widget.sender),
              _buildInfoRow('ผู้รับ', widget.receiver),
              _buildInfoRow('ที่อยู่ผู้รับ', widget.receiverAddress),
              _buildInfoRow('สถานะการจัดส่ง', widget.deliveryStatus),
              _buildInfoRow('ผู้จัดส่ง', widget.rider),
              _buildInfoRow('วันที่จัดส่ง', widget.deliveryDate.toLocal().toString()),
              if (widget.completionDate != null)
                _buildInfoRow('วันที่จัดส่งเสร็จสิ้น', widget.completionDate!.toLocal().toString()),
              SizedBox(height: 20),
              Text(
                'รูปภาพสินค้า',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.itemImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.itemImages[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                'แผนที่',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
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
                        (widget.senderLocation.latitude + widget.receiverLocation.latitude) / 2,
                        (widget.senderLocation.longitude + widget.receiverLocation.longitude) / 2,
                      ),
                      zoom: 12.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
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
                            builder: (ctx) => Icon(Icons.location_on, color: Colors.blue),
                          ),
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: widget.receiverLocation,
                            builder: (ctx) => Icon(Icons.location_on, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : _buildInfoRow('ระยะทาง', '${_distance.toStringAsFixed(2)} กิโลเมตร'),
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
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}