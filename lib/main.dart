// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_service.dart';
import 'ui/home_screen.dart';
//import 'can_bus_service.dart';
import 'package:flutter_background/flutter_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "Revving Up",
    notificationText: "Engine sound is playing",
    notificationImportance: AndroidNotificationImportance.normal,
    enableWifiLock: true,
  );

  bool hasPermissions = await FlutterBackground.hasPermissions;
  if (hasPermissions) {
    await FlutterBackground.initialize(androidConfig: androidConfig);
    await FlutterBackground.enableBackgroundExecution();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AudioService(),
      child: MaterialApp(
        title: 'Revving Up',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
