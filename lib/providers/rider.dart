import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class RiderState {
  final Map<String, dynamic>? data;
  
  RiderState({this.data});

  RiderState copyWith({Map<String, dynamic>? data}) {
    return RiderState(data: data ?? this.data);
  }
}

class RiderNotifier extends StateNotifier<RiderState> {
  RiderNotifier() : super(RiderState());

  StreamSubscription<DocumentSnapshot>? _listener;

  void setListener(StreamSubscription<DocumentSnapshot> listener) {
    _listener = listener;
  }

  void update(Map<String, dynamic>? data) {
    state = state.copyWith(data: data);
  }

  Future<void> cancel() async {
    await _listener?.cancel();
    _listener = null;
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }
}

final riderProvider = StateNotifierProvider<RiderNotifier, RiderState>((ref) {
  return RiderNotifier();
});