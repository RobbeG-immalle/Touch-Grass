import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/app.dart';
import 'package:touch_grass/providers/auth_provider.dart';
import 'package:touch_grass/providers/posts_provider.dart';
import 'package:touch_grass/providers/friends_provider.dart';
import 'package:touch_grass/providers/settings_provider.dart';
import 'package:touch_grass/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;
  try {
    // Attempt to initialize Firebase. Requires firebase_options.dart to be
    // generated via `flutterfire configure`. See firebase_options_template.dart.
    await Firebase.initializeApp();
    firebaseInitialized = true;
  } catch (_) {
    // Firebase config not present — app runs in demo/mock mode.
  }

  if (firebaseInitialized) {
    await NotificationService.instance.initialize();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(firebaseAvailable: firebaseInitialized),
        ),
        ChangeNotifierProxyProvider<AuthProvider, PostsProvider>(
          create: (_) => PostsProvider(),
          update: (_, auth, posts) => (posts ?? PostsProvider())
            ..updateUser(auth.currentUser),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FriendsProvider>(
          create: (_) => FriendsProvider(),
          update: (_, auth, friends) => (friends ?? FriendsProvider())
            ..updateUser(auth.currentUser),
        ),
      ],
      child: const TouchGrassApp(),
    ),
  );
}
