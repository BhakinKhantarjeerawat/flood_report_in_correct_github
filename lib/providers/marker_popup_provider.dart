import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flood.dart';

/// State for marker popup
class MarkerPopupState {
  final Flood? selectedFlood;
  final bool isVisible;

  const MarkerPopupState({
    this.selectedFlood,
    this.isVisible = false,
  });

  MarkerPopupState copyWith({
    Flood? selectedFlood,
    bool? isVisible,
  }) {
    return MarkerPopupState(
      selectedFlood: selectedFlood ?? this.selectedFlood,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// Notifier for managing marker popup state
class MarkerPopupNotifier extends StateNotifier<MarkerPopupState> {
  MarkerPopupNotifier() : super(const MarkerPopupState());

  /// Show popup with selected flood
  void showPopup(Flood flood) {
    state = state.copyWith(
      selectedFlood: flood,
      isVisible: true,
    );
  }

  /// Hide popup
  void hidePopup() {
    state = state.copyWith(
      selectedFlood: null,
      isVisible: false,
    );
  }
}

/// Provider for marker popup state
final markerPopupProvider = StateNotifierProvider<MarkerPopupNotifier, MarkerPopupState>(
  (ref) => MarkerPopupNotifier(),
);
