import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PipState {
  idle,
  listening,
  speaking,
  thinking,
  happy,
  celebrating,
}

class PipNotifier extends StateNotifier<PipState> {
  PipNotifier() : super(PipState.idle);

  void updateState(PipState newState) {
    state = newState;
  }

  void celebrate() {
    state = PipState.celebrating;
  }

  void think() {
    state = PipState.thinking;
  }

  void listen() {
    state = PipState.listening;
  }

  void speak() {
    state = PipState.speaking;
  }

  void makeHappy() {
    state = PipState.happy;
  }

  void reset() {
    state = PipState.idle;
  }
}

final pipStateProvider = StateNotifierProvider<PipNotifier, PipState>((ref) {
  return PipNotifier();
});
