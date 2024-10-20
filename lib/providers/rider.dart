import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:latlong2/latlong.dart';

class RiderState {
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? routePoints;
  final Map<String, dynamic>? currentWork;

  RiderState({this.data, this.routePoints, this.currentWork});

  RiderState copyWith(
      {Map<String, dynamic>? data,
      Map<String, dynamic>? routePoints,
      Map<String, dynamic>? currentWork}) {
    return RiderState(
        data: data ?? this.data,
        routePoints: routePoints ?? this.routePoints,
        currentWork: this.currentWork);
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

  void updateRoutePoints(Map<String, dynamic>? data) async {
    state = state.copyWith(routePoints: data);
  }

  void updateCurrentWork(Map<String, dynamic>? data) {
    state = state.copyWith(currentWork: data);
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
