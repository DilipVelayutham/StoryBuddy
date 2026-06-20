import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/story_buddy/presentation/screens/splash_screen.dart';

void main() {
  // Capture Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // In production we would log this to a crash reporting dashboard like Crashlytics
    debugPrint('Uncaught Flutter Error: ${details.exceptionAsString()}');
  };

  // Run app inside guarded zone for general exceptions
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
      const ProviderScope(
        child: StoryBuddyApp(),
      ),
    );
  }, (error, stackTrace) {
    debugPrint('Uncaught Async Error: $error');
  });
}

class StoryBuddyApp extends StatelessWidget {
  const StoryBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
