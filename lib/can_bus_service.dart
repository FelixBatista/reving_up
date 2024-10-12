/*
Steps:
1.Create Native Modules:
  Implement CAN bus communication in Kotlin/Java using existing libraries or the code from TeyesCanBusGolf7RZC.

2.Expose Methods to Dart:
  Use platform channels to send and receive RPM data.

3.Handle Permissions:
  Ensure the app has necessary permissions to access CAN bus interfaces.
 */

// can_bus_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class CanBusService {
  Future<int> getEngineRPM();
}

class RealCanBusService implements CanBusService {
  static const platform = MethodChannel('reving_up/canbus');

  @override
  Future<int> getEngineRPM() async {
    try {
      final int rpm = await platform.invokeMethod('getRPM');
      return rpm;
    } on PlatformException catch (e) {
      print("Failed to get RPM: ${e.message}");
      return 0;
    }
  }
}

class MockCanBusService implements CanBusService {
  int currentRPM = 1000;
  Timer? timer;

  MockCanBusService() {
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      // Simulate RPM changes
      currentRPM += 100;
      if (currentRPM > 8000) currentRPM = 1000;
    });
  }

  @override
  Future<int> getEngineRPM() async {
    return currentRPM;
  }
}

CanBusService getCanBusService() {
  if (kIsWeb ||
      !['android', 'ios'].contains(defaultTargetPlatform.toString().toLowerCase())) {
    return MockCanBusService();
  } else {
    return RealCanBusService();
  }
}
