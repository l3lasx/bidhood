import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String orderId;
  final String sender;
  final String receiver;
  final String receiverAddress;
  final List<String> itemImages;
  final String deliveryStatus;
  final String rider;
  final DateTime deliveryDate;
  final DateTime? completionDate;

  const ItemCard({
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white, // เพิ่มบรรทัดนี้เพื่อกำหนดพื้นหลังเป็นสีขาว
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
            Text('Delivery Status: $deliveryStatus'),
            const SizedBox(height: 8),
            Text('Rider: $rider'),
            const SizedBox(height: 8),
            Text('Delivery Date: ${deliveryDate.toLocal()}'),
            if (completionDate != null)
              Text('Completion Date: ${completionDate!.toLocal()}'),
            const SizedBox(height: 8),
            SizedBox(
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
          ],
        ),
      ),
    );
  }
}
