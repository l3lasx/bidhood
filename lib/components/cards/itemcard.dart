// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String orderId;
  final String sender;
  final String receiver;
  final String receiverAddress;
  final List<String> itemImages;
  final int deliveryStatus;
  final List<String> des;
  final String? rider;
  final DateTime? deliveryDate;
  final DateTime? completionDate;
  final VoidCallback onTap;
  final bool isCompleted;

  const ItemCard(
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
      required this.onTap,
      required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final List<String> _steps = [
      '',
      'รอไรเดอร์มารับสินค้า',
      'ไรเดอร์รับงาน',
      'ไรเดอร์เข้ารับพัสดุ',
      'รับสินค้าแล้วกำลังเดินทาง',
      'นำส่งสินค้าแล้ว',
    ];

    final List<Color> _colors = [
      const Color(0xFF000000),
      const Color(0xFFFFB74D), // สีส้มอ่อน
      const Color(0xFF29B6F6), // สีฟ้า
      const Color(0xFF1E88E5), // สีฟ้าเข้ม
      const Color(0xFF3949AB), // สีน้ำเงิน
      const Color(0xFF8BC34A), // สีเขียวอ่อน
      const Color(0xFF43A047), // สีเขียวเข้ม
    ];

    String _getStepText(int status) {
      if (_steps == null || status >= _steps.length) {
        return 'Unknown';
      }
      return _steps[status] ?? 'Unknown';
    }

    Color _getStepColor(int status) {
      if (_colors == null || status >= _colors.length) {
        return Colors.grey;
      }
      return _colors[status] ?? Colors.grey;
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID: $orderId',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Sender: $sender'),
              const SizedBox(height: 8),
              Text('Receiver: $receiver'),
              const SizedBox(height: 8),
              Text('Receiver Address: $receiverAddress'),
              const SizedBox(height: 8),
              if (rider != null && rider!.isNotEmpty) ...[
                Text('Rider: $rider'),
                const SizedBox(height: 8),
                if (deliveryDate != null)
                  Text('Delivery Date: ${deliveryDate?.toLocal()}'),
                if (completionDate != null)
                  Text('Completion Date: ${completionDate!.toLocal()}'),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: 100,
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: itemImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(itemImages[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getStepColor(deliveryStatus),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getStepText(deliveryStatus),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      ])),
            ],
          ),
        ),
      ),
    );
  }
}
