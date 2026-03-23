# 🌿 Touch Grass

> *Put your phone down. Go outside. Touch some grass.*

**Touch Grass** is a social media app with a twist — it **rewards you for going outside**. Post a photo of yourself in nature, maintain your daily streak, and see where your friends are exploring on the map.

---

## ✨ Features

- 📸 **Daily Photo Posts** — Share outdoor moments with friends or publicly
- 🔥 **Streaks** — Keep your daily outdoor streak alive; miss a day and it resets
- 🗺️ **Explore Map** — See public posts pinned on a world map
- 🏆 **Hot Pics** — Browse the most-liked outdoor photos this week
- 👫 **Friends** — Add friends, see their streaks, keep each other accountable
- 🔔 **Smart Notifications** — Daily reminder to go touch grass (customizable time)
- 🌙 **Dark Mode** — Full dark mode support
- 🔒 **Privacy Controls** — Post to friends-only or publicly

---

## 📱 Screenshots

> *Coming soon — add your screenshots here*

| Home Feed | Explore Map | Profile | Hot Pics |
|-----------|-------------|---------|----------|
| ![Home]() | ![Map]() | ![Profile]() | ![Hot]() |

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart) |
| State Management | Provider |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| File Storage | Firebase Storage |
| Push Notifications | Firebase Cloud Messaging |
| Local Notifications | flutter_local_notifications |
| Maps | Google Maps Flutter |
| Camera / Gallery | image_picker |
| Navigation | GoRouter |
| Fonts | Google Fonts (Poppins) |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.0.0
- A Firebase project ([console.firebase.google.com](https://console.firebase.google.com))
- Google Maps API key (for the Explore screen)

### 1. Clone the repo

```bash
git clone https://github.com/your-username/Touch-Grass.git
cd Touch-Grass
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** (Email/Password + Google)
3. Create a **Firestore** database
4. Enable **Firebase Storage**
5. Enable **Firebase Cloud Messaging**
6. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
7. Run:
   ```bash
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` (already gitignored).

> A template is provided at `firebase_options_template.dart`. The app will show a setup warning if the real config is missing.

### 4. Configure Google Maps

**Android** — add your key to `android/local.properties` (gitignored):
```properties
MAPS_API_KEY=your_google_maps_api_key_here
```
The key is injected into the manifest automatically via Gradle.

**iOS** — add your key to `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY")
```

**Web** — copy the template and add your key:
```bash
cp web/maps_config.js.template web/maps_config.js
# then edit web/maps_config.js and set your API key
```

### 5. Run the app

```bash
flutter run
```

---

## 🏗 Project Structure

```
lib/
├── main.dart              # App entry point, Firebase init
├── app.dart               # Root widget, GoRouter setup
├── config/
│   ├── theme.dart         # Material 3 theme (light + dark)
│   ├── routes.dart        # GoRouter route definitions
│   └── constants.dart     # App-wide constants
├── models/
│   ├── user_model.dart
│   ├── post_model.dart
│   └── friendship_model.dart
├── services/
│   ├── auth_service.dart
│   ├── database_service.dart
│   ├── storage_service.dart
│   ├── notification_service.dart
│   └── location_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── posts_provider.dart
│   ├── friends_provider.dart
│   └── settings_provider.dart
├── screens/               # All app screens
└── widgets/               # Reusable UI components
```

---

## 🔥 Streak Rules

- Post today → streak increments (or stays if already posted today)
- Miss a day → streak **resets to 1** on next post
- Miss 2+ days → streak broken

---

## 🔮 Roadmap

- [ ] Stories / 24-hour disappearing posts
- [ ] Leaderboard for longest streaks
- [ ] AR camera filters for outdoor detection
- [ ] Apple Sign-In
- [ ] AI-powered outdoor verification

---

*Made with 💚 for the chronically indoor*
