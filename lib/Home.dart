import 'dart:io';
import 'package:flutter/material.dart';
import 'ControlPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _ipController = TextEditingController();
  Socket? _socket;

  void _checkAndNavigate() async {
    String ip = _ipController.text;
    try {
      _socket = await Socket.connect(ip, 80, timeout: Duration(seconds: 5));
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ControlPage(socket: _socket!, ip: ip)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not connect to the server: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery for responsive layout
    var size = MediaQuery.of(context).size;
    var paddingTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    'assets/images/logo.png', // Replace with your image asset
                    width: size.width * 0.4,
                    height: size.height * 0.1,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _ipController,
                  decoration: InputDecoration(
                    hintText: 'Enter IP Address',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkAndNavigate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 19, 221, 80),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                  child: Text('Check and Connect'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
