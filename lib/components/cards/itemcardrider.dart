// ignore_for_file: non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ItemCardRider extends StatelessWidget {
  final String orderId;
  final String pickupAddress;
  final String deliveryAddress;
  final String pickupImage;
  final double rider_goto_sender_distance;
  final VoidCallback onViewDetails;

  const ItemCardRider({
    super.key,
    required this.orderId,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.rider_goto_sender_distance,
    required this.pickupImage,
    required this.onViewDetails,
  });

  String formatDistance(double distanceInKm) {
    if (distanceInKm >= 1) {
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      int meters = (distanceInKm * 1000).round();
      if (meters < 1) {
        int cm = (distanceInKm * 100000).round(); // แปลงเป็นเซนติเมตร
        return '$cm cm';
      }
      return '$meters m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white, // เพิ่มบรรทัดนี้เพื่อกำหนดสีพื้นหลังเป็นสีขาว
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: $orderId',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Timeline
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      TimelineTile(
                        alignment: TimelineAlign.start,
                        isFirst: true,
                        indicatorStyle: const IndicatorStyle(
                          width: 20,
                          color: Colors.green,
                          padding: EdgeInsets.all(6),
                        ),
                        beforeLineStyle: const LineStyle(
                          color: Colors.grey,
                          thickness: 2,
                        ),
                        afterLineStyle: const LineStyle(
                          color: Colors.grey,
                          thickness: 2,
                        ),
                        endChild: _buildTimelineContent(
                            'จุดรับสินค้า', pickupAddress),
                      ),
                      TimelineTile(
                        alignment: TimelineAlign.start,
                        isLast: true,
                        indicatorStyle: const IndicatorStyle(
                          width: 20,
                          color: Colors.red,
                          padding: EdgeInsets.all(6),
                        ),
                        beforeLineStyle: const LineStyle(
                          color: Colors.grey,
                          thickness: 2,
                        ),
                        endChild: _buildTimelineContent(
                            'จุดส่งสินค้า', deliveryAddress),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ระยะทางไปหาผู้ส่ง",
                              style: TextStyle(fontSize: 14)),
                          Text(formatDistance(rider_goto_sender_distance),
                              style: const TextStyle(fontSize: 12))
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right side: Image and Button
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: pickupImage,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          )),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: onViewDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('รายละเอียด'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineContent(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
