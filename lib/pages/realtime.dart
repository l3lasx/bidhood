// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:bidhood/providers/rider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RealTimePage extends ConsumerStatefulWidget {
  final String transactionID;
  const RealTimePage({super.key, required this.transactionID});

  @override
  ConsumerState<RealTimePage> createState() => _RealTimePageState();
}

class _RealTimePageState extends ConsumerState<RealTimePage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        startRealtimeGet();
      }
    });
  }

  void startRealtimeGet() {
    if (widget.transactionID.isNotEmpty) {
      final docRef = db.collection("transactions").doc(widget.transactionID);

      final notifier = ref.read(riderProvider.notifier);

      notifier.setListener(docRef.snapshots().listen(
        (event) {
          if (mounted) {
            var data = event.data();
            notifier.update(data);
            debugPrint("current data: $data");
          }
        },
        onError: (error) => debugPrint("Listen failed: $error"),
      ));
    } else {
      debugPrint("transactionID is not valid: ${widget.transactionID}");
    }
  }

  void stopRealTime() {
    if (_disposed) return;
    if (mounted) {
      final notifier = ref.read(riderProvider.notifier);
      notifier.cancel();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    stopRealTime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = ref.watch(riderProvider).data;
    return Scaffold(
      appBar: AppBar(title: const Text("Real Time Channel")),
      body: SafeArea(
        child: Center(
          child: data == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('OrderID: ${data['order_id'] ?? 'N/A'}'),
                    Text(
                        'Receiver Lat: ${data['receiver_location']?['Lat'] ?? 'N/A'}'),
                    Text(
                        'Receiver Long: ${data['receiver_location']?['Long'] ?? 'N/A'}'),
                    Text(
                        'Rider Lat: ${data['rider_location']?['Lat'] ?? 'N/A'}'),
                    Text(
                        'Rider Long: ${data['rider_location']?['Long'] ?? 'N/A'}'),
                    Text(
                        'RiderStart Lat: ${data['rider_start_location']?['Lat'] ?? 'N/A'}'),
                    Text(
                        'RiderStart Long: ${data['rider_start_location']?['Long'] ?? 'N/A'}'),
                    Text(
                        'Sender Lat: ${data['sender_location']?['Lat'] ?? 'N/A'}'),
                    Text(
                        'Sender Long: ${data['sender_location']?['Long'] ?? 'N/A'}'),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => context.go('/homerider'),
                      child: const Text("Back"),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
