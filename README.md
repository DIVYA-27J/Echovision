# Echo Vision 👁️

> **AI-Powered Assistive Object Detection & Emergency Support App**  
> *Flutter · TensorFlow Lite · On-Device ML · Emergency SMS*  
> Hackathon MVP — June 2026

---

## 📱 Overview

**Echo Vision** is an Android accessibility app designed for visually impaired users. It uses on-device AI to detect everyday objects in real time and announces them aloud via Text-to-Speech (TTS). When a user says **"Help me"**, the app sends an emergency SMS with GPS coordinates to a pre-configured contact.

> 🔒 **Privacy first**: All AI inference runs entirely on-device. No camera frames or audio are ever transmitted over the internet.

---

## ✨ Features

| Feature | Technology |
|---|---|
| Real-time object detection | TensorFlow Lite (MobileNetV2 SSD) |
| Voice announcements | flutter_tts |
| "Help me" voice command | speech_to_text |
| Emergency SMS with GPS | telephony + geolocator |
| Settings persistence | shared_preferences |
| On-device ML (offline) | TFLite / Google ML Kit |

---

## 🏗️ Architecture

```
Presentation Layer   →  Flutter Widgets (Screens, Overlays, Widgets)
Domain Logic Layer   →  Dart Services (Detection, TTS, Memory, Emergency)
AI Inference Layer   →  TFLite MobileNetV2 / Google ML Kit (on-device)
Device APIs          →  Camera, Microphone, GPS, SMS (Flutter Plugins)
Persistence Layer    →  In-memory (session) + SharedPreferences (settings)
```

---

## 📁 Project Structure

```
echo_vision/
├── android/
│   ├── app/
│   │   ├── src/main/AndroidManifest.xml   ← Permissions
│   │   └── build.gradle                   ← TFLite aaptOptions
│   ├── build.gradle
│   └── settings.gradle
├── lib/
│   ├── main.dart                           ← App entry + MultiProvider
│   ├── screens/
│   │   ├── splash_screen.dart             ← Permissions + launch
│   │   ├── camera_screen.dart             ← Live detection UI
│   │   └── settings_screen.dart           ← Emergency contact + language
│   ├── services/
│   │   ├── detection_service.dart         ← TFLite inference
│   │   ├── mlkit_detection_service.dart   ← ML Kit alternative
│   │   ├── tts_service.dart               ← Text-to-Speech
│   │   ├── speech_service.dart            ← Speech-to-Text
│   │   ├── memory_service.dart            ← In-session state
│   │   ├── location_service.dart          ← GPS
│   │   ├── emergency_service.dart         ← SOS SMS
│   │   └── settings_service.dart          ← SharedPreferences
│   ├── models/
│   │   ├── detection_result.dart          ← Data model
│   │   └── session_state.dart             ← Session model
│   ├── widgets/
│   │   ├── detection_overlay.dart         ← Label + confidence bar
│   │   ├── status_bar.dart                ← Bottom status strip
│   │   └── help_button.dart               ← Pulsing SOS button
│   └── utils/
│       ├── permission_helper.dart         ← Runtime permissions
│       └── constants.dart                 ← App-wide constants
├── assets/
│   └── models/
│       ├── labels.txt                     ← COCO 80-class labels
│       └── mobilenet.tflite               ← TFLite model (download separately)
├── test/
│   └── detection_service_test.dart        ← Unit tests
└── pubspec.yaml
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Android device with camera (API 21+)
- Android Studio / VS Code

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Download TFLite model

Download **MobileNetV2 SSD COCO** from TensorFlow Hub:

```bash
# Option A — TFLite Model Maker (recommended for hackathon)
# Download from: https://tfhub.dev/tensorflow/lite-model/ssd_mobilenet_v1/1/metadata/2

# Copy to assets:
cp mobilenet.tflite assets/models/mobilenet.tflite
```

Alternatively, use **Google ML Kit** (no model file needed) by switching to `MLKitDetectionService` in `camera_screen.dart`.

### 3. Run on device

```bash
flutter run
```

### 4. Build release APK

```bash
# Standard release
flutter build apk --release

# With obfuscation (recommended)
flutter build apk --release --obfuscate --split-debug-info=./debug-info

# Install via ADB
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## ⚙️ Configuration

Open the **Settings** screen in the app to configure:
- **Emergency Contact**: Phone number that receives the SOS SMS
- **TTS Language**: Language for object announcements (supports 8 languages)

---

## 🔐 Permissions

| Permission | Required | Purpose |
|---|---|---|
| CAMERA | ✅ Yes | Live object detection |
| RECORD_AUDIO | ✅ Yes | "Help me" voice command |
| ACCESS_FINE_LOCATION | Optional | GPS in emergency SMS |
| SEND_SMS | Optional | Emergency SMS dispatch |
| READ_PHONE_STATE | Optional | Telephony features |

---

## 📊 Confidence Thresholds

| Range | Behaviour |
|---|---|
| < 0.40 | Detection ignored |
| 0.40 – 0.55 | Logged silently, no TTS |
| 0.55 – 0.75 | Object announced via TTS ✅ |
| > 0.75 | Announced + stored immediately ✅✅ |

---

## 🗺️ Future Roadmap

- Turn-by-turn navigation (ARCore + Maps API)
- OCR for text reading (menus, signs)
- Scene description (Gemini Vision API)
- Multi-language TTS & STT
- WearOS companion app

---

## 👩‍💻 Built With

- [Flutter](https://flutter.dev/) — Cross-platform UI framework
- [TensorFlow Lite](https://www.tensorflow.org/lite) — On-device ML
- [Google ML Kit](https://developers.google.com/ml-kit) — Alternative detector
- [flutter_tts](https://pub.dev/packages/flutter_tts) — Text-to-Speech
- [speech_to_text](https://pub.dev/packages/speech_to_text) — Speech recognition

---

*Echo Vision — Empowering Independence for Visually Impaired Users*
