import 'package:flutter/material.dart';
import 'theme/thravix_theme.dart';
import 'screens/turnstile_hub_screen.dart';

void main() {
  runApp(const ThravixApp());
}

class ThravixApp extends StatelessWidget {
  const ThravixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thravix Gate',
      debugShowCheckedModeBanner: false,
      theme: ThravixTheme.themeData,
      home: const TurnstileHubScreen(),
    );
  }
}
