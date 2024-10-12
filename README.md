Under Development

# Revving Up

Revving Up is a Flutter-based car application that uses real-time CAN bus data to emulate engine sounds based on the RPM of the vehicle. The app plays sound snippets from real engine recordings, providing a realistic engine audio experience that adjusts based on the RPM. The app is designed to be used on Android head units in vehicles and can be customized with different engine sounds, such as a V8 Mustang or a V12 F1 engine.

## Features

- **Real-time RPM-based Engine Sound Emulation**: Uses CAN bus data to dynamically adjust engine sounds based on RPM.
- **Engine Sound Selection**: Choose from different engine sounds, such as V8 Mustang or V12 F1.
- **Volume Control**: Adjust the engine sound volume directly from the app.
- **Gapless Playback**: The app ensures seamless playback for a smooth and immersive experience, avoiding any interruptions when switching between sound snippets or looping.
- **Custom Engine Sounds**: Support for multiple engines, where each engine has its own sound snippets divided into RPM ranges.
- **Crossfade (optional)**: Crossfade between RPM snippets for smoother transitions (if desired).

## How It Works

The app receives real-time RPM data from the CAN bus of the vehicle and plays corresponding sound snippets (MP3 files) that are mapped to the RPM range. For example, the app has sound snippets for 1,000 RPM, 2,000 RPM, and so on, up to the maximum RPM defined by the user. As the RPM changes, the app dynamically switches between the appropriate sound snippets, providing an engine sound experience that matches the vehicle's current speed.

Each engine sound is divided into 10 sound snippets (from 1,000 RPM to the maximum RPM) stored as MP3 files, ensuring smooth and realistic audio transitions. The app ensures **gapless looping** and provides volume controls.

## Project Structure

```
revving_up/
├── assets/
│   ├── sounds/
│   │   ├── v8_mustang/
│   │   │   ├── acc_1.mp3
│   │   │   ├── acc_2.mp3
│   │   │   ├── ...
│   │   └── v12_f1/
│   │       ├── acc_1.mp3
│   │       ├── acc_2.mp3
│   │       ├── ...
├── lib/
│   ├── audio_service.dart
│   ├── can_bus_service.dart
│   └── home_screen.dart
├── pubspec.yaml
└── README.md
```

- **assets/sounds/**: This directory contains folders for each engine sound (e.g., `v8_mustang`, `v12_f1`), and each folder contains sound snippets named `acc_X.mp3`, where `X` is the RPM range.
- **lib/audio_service.dart**: Handles audio playback, gapless looping, and engine sound selection.
- **lib/can_bus_service.dart**: Handles the communication with the CAN bus to retrieve real-time RPM data.
- **lib/home_screen.dart**: The main UI of the application, where users can select engine sounds, adjust the maximum RPM, and control volume.

## Prerequisites

- **Flutter SDK**: Install the Flutter SDK on your development machine.
- **Android SDK**: Make sure you have Android SDK installed and properly configured for development.
- **CAN Bus Interface**: The app expects to receive RPM data via a CAN bus interface. You can use any appropriate interface for your vehicle, such as [this example CAN bus interface](https://github.com/iscle/TeyesCanBusGolf7RZC).

## Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-repo/revving-up.git
   ```

2. **Navigate into the project directory**:
   ```bash
   cd revving-up
   ```

3. **Install dependencies**:
   Run the following command to install the Flutter dependencies:
   ```bash
   flutter pub get
   ```

4. **Add your engine sounds**:
    - Place your sound snippets inside the `assets/sounds/` directory. Each engine sound should have its own folder (e.g., `v8_mustang`), and each folder should contain MP3 files named `acc_X.mp3` where `X` corresponds to the RPM snippet.

5. **Configure the CAN bus service**:
    - Modify `can_bus_service.dart` to correctly interface with your vehicle’s CAN bus and retrieve the real-time RPM data. The RPM data will drive the engine sound playback.

6. **Run the app on an Android device**:
    - Connect your Android head unit or use an Android emulator.
   ```bash
   flutter run
   ```

## Usage

- When the app starts, you can:
    1. Select an engine from the dropdown list (e.g., V8 Mustang, V12 F1).
    2. Set the maximum RPM of your vehicle.
    3. Adjust the volume of the engine sound.
    4. The app will start playing the engine sound as the RPM data is received from the CAN bus.

## Customization

- **Adding New Engine Sounds**:
  To add a new engine sound, create a new folder under `assets/sounds/` with the engine name (e.g., `v12_ferrari`). Inside this folder, place your MP3 files named `acc_1.mp3`, `acc_2.mp3`, ..., `acc_10.mp3`, corresponding to different RPM ranges.

- **Adjust Crossfade (if using crossfading)**:
  You can adjust the crossfade duration between RPM snippets in the `audio_service.dart` file by changing the delay between fading out and fading in new snippets.

## Known Issues

- **RPM Data**: Ensure that the CAN bus interface is correctly providing real-time RPM data for the best experience.
- **MP3 Gaps**: If you notice gaps in the MP3 playback, ensure that your MP3 files are properly encoded and trimmed for gapless playback.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
```