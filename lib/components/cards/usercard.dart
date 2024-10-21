import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String imageUrl;
  final String fullName;
  final String address;
  final String phoneNumber;

  const UserCard({
    Key? key,
    required this.imageUrl,
    required this.fullName,
    required this.address,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: Colors.white, // กำหนดพื้นหลังของ card เป็นสีขาว
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพด้านซ้าย (เป็นวงกลม)
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(width: 16),
            // ข้อมูลผู้ใช้ด้านขวา
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(child: Text(address)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16),
                      const SizedBox(width: 4),
                      Text(phoneNumber),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}