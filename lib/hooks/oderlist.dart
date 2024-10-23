import 'package:bidhood/components/bottomsheet/item_details_bottomsheet.dart';
import 'package:bidhood/components/cards/itemcard.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class OrderListView extends StatefulWidget {
  final Future<Map<String, dynamic>> orderFuture;
  final String userRole;
  const OrderListView({
    super.key,
    required this.orderFuture,
    required this.userRole,
  });

  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: widget.orderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final orderListData = snapshot.data?['data']?['data'];
          if (orderListData == null || orderListData.isEmpty) {
            return _buildEmptyState();
          }
          return _buildOrderList(context, orderListData);
        } else {
          return _buildEmptyState();
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return const Expanded(
      child: Center(
        child: Text(
          'ขออภัยไม่มีรายการของคุณ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List orderListData) {
    orderListData.sort((a, b) {
      DateTime dateA = DateTime.parse(a['created_at']);
      DateTime dateB = DateTime.parse(b['created_at']);
      return dateB.compareTo(dateA); // เรียงจากใหม่ไปเก่า (DESC)
    });

    return Expanded(
      child: ListView.builder(
        itemCount: orderListData.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          var order = orderListData[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ItemCard(
              onTap: () => _showItemDetails(context, order),
              orderId: order['order_id'] ?? '',
              sender: order['user']['fullname'] ?? '',
              receiver: order['receiver']['fullname'] ?? '',
              receiverAddress: order['receiver']['address'] ?? '',
              itemImages: _getItemImages(order),
              deliveryStatus: order['status'] ?? 0,
              isCompleted: order['is_order_complete'] ?? false,
              des: _getItemDescription(order),
              rider: order['rider']['fullname'] ?? '',
              deliveryDate: DateTime.now(),
              completionDate: null,
            ),
          );
        },
      ),
    );
  }

  void _showItemDetails(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return ItemDetailsDrawer(
              transactionID: order['order_transaction_id'],
              orderId: order['order_id'] ?? '',
              sender: order['user']['fullname'] ?? '',
              receiver: order['receiver']['fullname'] ?? '',
              receiverAddress: order['receiver']['address'] ?? '',
              itemImages: _getItemImages(order),
              deliveryStatus: order['status'] ?? 0,
              des: _getItemDescription(order),
              rider: order['rider_id'],
              deliveryDate: DateTime.now(),
              completionDate: null,
              senderLocation: LatLng(
                order['user']['location']['lat'],
                order['user']['location']['long'],
              ),
              receiverLocation: LatLng(
                order['receiver']['location']['lat'],
                order['receiver']['location']['long'],
              ),
              userRole: widget.userRole,
            );
          },
        );
      },
    );
  }

  List<String> _getItemImages(Map<String, dynamic> order) {
    return (order['product_list'] as List?)
            ?.map<String>((item) => item['image'] as String)
            .toList() ??
        [];
  }
  List<String> _getItemDescription(Map<String, dynamic> order) {
    return (order['product_list'] as List?)
            ?.map<String>((item) => item['description'] as String)
            .toList() ??
        [];
  }
}
