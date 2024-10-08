// home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../audio_service.dart';
import '../can_bus_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedEngine = 'V12 F1';
  double volume = 0.5;
  int currentRPM = 0;
  int maxRPM = 8000; // Default max RPM

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _maxRPMController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _maxRPMController.text = maxRPM.toString();
    // Start listening to RPM updates
    startRPMListener();
  }

  void startRPMListener() async {
    CanBusService canBus = getCanBusService();
    AudioService audioService = Provider.of<AudioService>(context, listen: false);

    while (true) {
      int rpm = await canBus.getEngineRPM();
      setState(() {
        currentRPM = rpm;
      });
      audioService.updateRPM(rpm, maxRPM);
      await Future.delayed(Duration(milliseconds: 100)); // Adjust as needed
    }
  }

  @override
  void dispose() {
    _maxRPMController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AudioService audioService = Provider.of<AudioService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Revving Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Maximum RPM Input
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _maxRPMController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Maximum RPM',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter maximum RPM';
                  }
                  final int? rpm = int.tryParse(value);
                  if (rpm == null || rpm <= 0) {
                    return 'Enter a valid positive number';
                  }
                  return null;
                },
                onFieldSubmitted: (value) {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      maxRPM = int.parse(value);
                    });
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            // Engine Selection Dropdown
            DropdownButton<String>(
              value: selectedEngine,
              onChanged: (String? newValue) {
                setState(() {
                  selectedEngine = newValue!;
                  audioService.selectEngine(newValue);
                });
              },
              items: <String>['V12 F1', 'V8', 'Inline-4']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            // Volume Slider
            Slider(
              value: volume,
              min: 0,
              max: 1,
              divisions: 10,
              label: "Volume: ${(volume * 100).round()}%",
              onChanged: (double value) {
                setState(() {
                  volume = value;
                  audioService.setVolume(value);
                });
              },
            ),
            SizedBox(height: 20),
            // Turn Off Button
            ElevatedButton(
              onPressed: () {
                audioService.stopEngine();
              },
              child: Text('Turn Off'),
            ),
            SizedBox(height: 20),
            // Current RPM Display
            Text(
              'Current RPM: $currentRPM',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
