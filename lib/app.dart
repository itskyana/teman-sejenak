import 'package:flutter/material.dart';
import 'core/core.dart';
import 'screens/splash_screen.dart';

/// Main application widget
/// 
/// This is the root widget of the Teman Sejenak app.
/// It configures the MaterialApp with proper theming and routing.
class TemanSejenakApp extends StatelessWidget {
  const TemanSejenakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App Info
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: AppTheme.light,
      // darkTheme: AppTheme.dark, // Uncomment when dark theme is ready
      
      // Initial Route
      home: const SplashScreen(),
      
      // TODO: Add named routes when navigation is refactored
      // routes: AppRoutes.routes,
      // onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LEGACY SUPPORT
// ══════════════════════════════════════════════════════════════════════════════

/// Old app class for backward compatibility
/// @deprecated Use [TemanSejenakApp] instead
class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const TemanSejenakApp();
  }
}
