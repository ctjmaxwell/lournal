import 'dart:async';
import 'package:flutter/foundation.dart';

class CooldownService with ChangeNotifier {
  Timer? _timer;
  DateTime? _passwordResetCooldownEnd;

  // Public getter to check remaining seconds
  int get passwordResetSecondsRemaining {
    if (_passwordResetCooldownEnd == null) {
      return 0;
    }
    final remaining = _passwordResetCooldownEnd!.difference(DateTime.now()).inSeconds;
    // Return remaining time, or 0 if it has passed
    return remaining > 0 ? remaining : 0;
  }

  // Check if the cooldown is active
  bool get isPasswordResetOnCooldown => passwordResetSecondsRemaining > 0;

  // Method to start the cooldown
  void startPasswordResetCooldown() {
    const duration = Duration(seconds: 30);
    _passwordResetCooldownEnd = DateTime.now().add(duration);
    
    // Start a timer that notifies listeners every second to update the UI
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPasswordResetOnCooldown) {
        _timer?.cancel();
      }
      // This will cause any listening widgets to rebuild
      notifyListeners();
    });
    // Notify listeners immediately to update the UI when cooldown starts
    notifyListeners();
  }

  // Clean up the timer when the service is no longer needed
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}