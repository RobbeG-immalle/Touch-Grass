import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/config/routes.dart';
import 'package:touch_grass/config/theme.dart';
import 'package:touch_grass/providers/settings_provider.dart';

class TouchGrassApp extends StatelessWidget {
  const TouchGrassApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp.router(
      title: 'Touch Grass',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
