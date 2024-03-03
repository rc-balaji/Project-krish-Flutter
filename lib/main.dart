// main.dart
import 'package:flutter/material.dart';
import 'Home.dart'; // Make sure the import path matches the location of your Home.dart file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoiceApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SafeArea(child: HomePage()),
    );
  }
}
