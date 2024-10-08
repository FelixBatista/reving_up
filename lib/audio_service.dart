/*
Steps:
1. Prepare Audio Assets:
  - Have engine sound files that loop seamlessly.
  - Optionally, have separate tracks for different RPM ranges.

2. Dynamic Playback with RPM Mapping:
  - Adjust the playback speed or pitch based on the ratio of current RPM to maximum RPM.
  - Ensure that the engine sound's maximum RPM aligns with the vehicle's maximum RPM.

3. Spatial Audio:
  - Use stereo panning to make the sound feel like it's coming from the engine's location.

4. RPM Mapping Formula:

playback rate = (currentRPM/User'sMaxRPM) x SoundMaxRPM

This ensures that as the vehicle's RPM approaches its maximum, the sound adjusts proportionally.

 */

// audio_service.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _currentEngine = 'v12_f1_engine';
  double _volume = 0.5;
  int _currentRPM = 0;
  int _userMaxRPM = 8000; // Default max RPM for mapping

  // Define the sound's maximum RPM
  final int _soundMaxRPM = 8000; // Adjust based on the sound asset's characteristics

  AudioService() {
    _initialize();
  }

  void _initialize() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(_volume);
    await _audioPlayer.play(AssetSource('sounds/$_currentEngine.mp3'));
  }

  void selectEngine(String engine) async {
    _currentEngine = engine.toLowerCase().replaceAll(' ', '_') + '_engine';
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/$_currentEngine.mp3'));
    notifyListeners();
  }

  void setVolume(double volume) {
    _volume = volume;
    _audioPlayer.setVolume(_volume);
    notifyListeners();
  }

  void stopEngine() {
    _audioPlayer.stop();
    notifyListeners();
  }

  void updateRPM(int rpm, int userMaxRPM) {
    _currentRPM = rpm;
    _userMaxRPM = userMaxRPM;

    // Calculate the proportional playback rate
    double rpmRatio = _currentRPM / _userMaxRPM;
    double playbackRate = rpmRatio * _soundMaxRPM;

    // Clamp the playback rate to the sound's max RPM to prevent distortion
    if (playbackRate > _soundMaxRPM) {
      playbackRate = _soundMaxRPM.toDouble();
    } else if (playbackRate < 0.0) {
      playbackRate = 0.0;
    }

    // Update the playback rate
    _audioPlayer.setPlaybackRate(playbackRate);

    notifyListeners();
  }
}
