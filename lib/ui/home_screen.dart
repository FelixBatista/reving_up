import 'package:flutter/material.dart';
import '../audio_service.dart';
import '../can_bus_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String selectedEngine = 'v8_mustang';
  double volume = 0.5;
  int currentRPM = 0;
  int maxRPM = 8000; // Default max RPM
  late AudioService audioService; // Make AudioService a class-level variable

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _maxRPMController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _maxRPMController.text = maxRPM.toString();
    audioService = Provider.of<AudioService>(context, listen: false);
    // Start listening to RPM updates
    startRPMListener();
  }

  void startRPMListener() async {
    CanBusService canBus = getCanBusService(); // Assume you have this setup

    while (true) {
      int rpm = await canBus.getEngineRPM(); // Assume this gets the current RPM from CAN bus
      setState(() {
        currentRPM = rpm;
      });
      // Play the correct sound snippet based on RPM
      audioService.playSoundForRPM(rpm);
      await Future.delayed(const Duration(milliseconds: 100)); // Adjust as needed
    }
  }

  @override
  void dispose() {
    _maxRPMController.dispose();
    audioService.stopEngine(); // Stop the engine sound when the screen is disposed
    super.dispose();
  }

  void _updateMaxRPM() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        maxRPM = int.parse(_maxRPMController.text);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum RPM updated to $maxRPM')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AudioService audioService = Provider.of<AudioService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revving Up'),
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
                decoration: const InputDecoration(
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
                  _updateMaxRPM();
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _updateMaxRPM,
              child: const Text('Set Maximum RPM'),
            ),
            const SizedBox(height: 20),
            // Engine Selection Dropdown
            DropdownButton<String>(
              value: selectedEngine,
              onChanged: (String? newValue) {
                setState(() {
                  selectedEngine = newValue!;
                  audioService.selectEngine(newValue); // Update selected engine in AudioService
                });
              },
              items: <String>['V12 F1', 'v8_mustang', 'Inline-4']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
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
                  audioService.setVolume(value); // Adjust the volume in AudioService
                });
              },
            ),
            const SizedBox(height: 20),
            // Turn off button
            ElevatedButton.icon(
              onPressed: () {
                audioService.toggleVolume(); // Toggle volume mute/un-mute
              },
              icon: Icon(audioService.volume > 0 ? Icons.volume_off : Icons.volume_up),
              label: Text(audioService.volume > 0 ? 'Turn Off' : 'Turn On'),
            ),
            const SizedBox(height: 20),
            // Current RPM Display
            Text(
              'Current RPM: $currentRPM',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
