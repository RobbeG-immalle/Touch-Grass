// lib/config/secrets_template.dart
//
// TEMPLATE ONLY - Do NOT commit a filled-in version of this file!
// 
// For production, use:
// 1. Firebase credentials (auto-handled by lib/firebase_options.dart)
// 2. Environment variables in .env (use flutter_dotenv to load)
// 3. Platform-specific configs (AndroidManifest.xml, AppDelegate.swift)
//
// This file shows the structure if you need to add other secrets in Dart.
// Copy to lib/config/secrets.dart and fill in locally (gitignored).

// const class SecretsConfig {
//   // Google Maps API Key
//   // Get from: https://console.cloud.google.com/google/maps-apis
//   static const String googleMapsApiKey = 'YOUR_MAPS_API_KEY';
//
//   // Google Sign-In OAuth Client IDs
//   // Get from: Firebase Console → Project Settings → Service Accounts
//   static const String googleOAuthClientId = 'YOUR_GOOGLE_OAUTH_CLIENT_ID';
//
//   // Add other secrets here as needed
// }

// ✅ Better approach: Use environment variables
//
// 1. Create .env file (copy from .env.template):
//    cp .env.template .env
//
// 2. Add flutter_dotenv to pubspec.yaml:
//    flutter pub add flutter_dotenv
//
// 3. Load in main.dart:
//    await dotenv.load(fileName: ".env");
//
// 4. Access in code:
//    final googleMapsKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
//
// This keeps secrets out of the Dart codebase entirely!
