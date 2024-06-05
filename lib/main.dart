// main.dart
import 'package:flutter/material.dart';
import 'pages/splash_screen_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VoiceApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SafeArea(child: SplashScreenPage()),
    );
  }
}
