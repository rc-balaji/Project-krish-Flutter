import 'dart:io';
import 'package:flutter/material.dart';

class ControlPage extends StatelessWidget {
  final Socket socket;
  final String ip;

  ControlPage({required this.socket, required this.ip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control Page'),
      ),
      body: Center(
        child: Text('Connected to $ip'),
      ),
    );
  }
}
