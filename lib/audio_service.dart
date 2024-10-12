import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioService with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer(); // Use just_audio's AudioPlayer
  String _currentEngineFolder = 'v8_mustang'; // Default engine folder
  double _volume = 0.5;
  int _userMaxRPM = 8000; // Default max RPM set by the user
  double _previousVolume = 0.5; // Store previous volume before muting
  int _currentSnippet = 1; // For managing sound snippets

  double get volume => _volume;
  String get currentEngineFolder => _currentEngineFolder;

  AudioService() {
    _initialize();
  }

  // Initialize the audio player with the default sound and prepare for gap-less playback
  void _initialize() async {
    _audioPlayer.setVolume(_volume);
    await preloadAllSnippets(); // Preload all snippets at startup
    await playSoundSnippet(_currentSnippet); // Play the default snippet
  }

  // Preload all snippets to avoid gaps during transitions
  Future<void> preloadAllSnippets() async {
    for (int i = 1; i <= 10; i++) {
      String fileName = 'sounds/$_currentEngineFolder/acc_$i.mp3';
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse('asset:///$fileName')));
    }
  }

  // Select a new engine folder
  void selectEngine(String engine) async {
    _currentEngineFolder = engine.toLowerCase().replaceAll(' ', '_');
    await _audioPlayer.stop(); // Stop the current playback
    await preloadAllSnippets(); // Preload the snippets for the new engine
    await playSoundSnippet(_currentSnippet); // Play the default snippet for the new engine
    notifyListeners();
  }

  // Set the volume for the audio player
  void setVolume(double volume) {
    _volume = volume;
    _audioPlayer.setVolume(_volume);
    notifyListeners();
  }

  // Toggle between mute and un-mute
  void toggleVolume() {
    if (_volume > 0) {
      _previousVolume = _volume; // Store current volume
      setVolume(0); // Mute
    } else {
      setVolume(_previousVolume); // Un-mute to previous volume
    }
  }

  // Stop the engine sound
  void stopEngine() {
    _audioPlayer.stop();
    notifyListeners();
  }

  // Play the appropriate sound snippet based on RPM
  Future<void> playSoundForRPM(int currentRPM) async {
    // Calculate the snippet number based on the current RPM and user-defined max RPM
    int snippet = ((currentRPM / _userMaxRPM) * 10).clamp(1, 10).ceil();

    // Only change the snippet if the snippet number has changed
    if (_currentSnippet != snippet) {
      _currentSnippet = snippet;
      // Play without crossfade
      await playSoundSnippet(snippet);
      // Play with crossfade
  //    await playSoundSnippetWithCrossfade(snippet);
    }
  }


      //Play without crossfade
  // Helper method to play a sound snippet based on the selected engine and snippet number
  Future<void> playSoundSnippet(int snippet) async {
    String fileName = 'sounds/$_currentEngineFolder/acc_$snippet.mp3';

    await _audioPlayer.setAsset('assets/$fileName');
    await _audioPlayer.setLoopMode(LoopMode.all); // Ensure gap-less looping
    await _audioPlayer.play(); // Start playback
  }


    //play with cross-fade
// Helper method to play a sound snippet with manual cross-fade
  Future<void> playSoundSnippetWithCrossfade(int snippet) async {
    // Fade out the current snippet
    await fadeOut();

    String fileName = 'sounds/$_currentEngineFolder/acc_$snippet.mp3';

    // Load the new snippet
    await _audioPlayer.setAsset('assets/$fileName');
    await _audioPlayer.setLoopMode(LoopMode.all); // Ensure gap-less looping

    // Fade in the new snippet
    await fadeIn();
    await _audioPlayer.play(); // Start playback
  }

  // Helper method to fade out the volume
  Future<void> fadeOut() async {
    double volume = _volume;
    while (volume > 0) {
      volume -= 0.1;
      await _audioPlayer.setVolume(volume);
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  // Helper method to fade in the volume
  Future<void> fadeIn() async {
    double volume = 0.0;
    while (volume < _volume) {
      volume += 0.1;
      await _audioPlayer.setVolume(volume);
      await Future.delayed(Duration(milliseconds: 100));
    }
  }
}
