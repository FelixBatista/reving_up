// can_bus_service.dart
import 'package:flutter/services.dart';

abstract class CanBusService {
  Future<int> getEngineRPM();
}

class RealCanBusService implements CanBusService {
  static const platform = MethodChannel('revving_up/canbus');

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
