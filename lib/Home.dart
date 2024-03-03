import 'dart:io';
import 'package:flutter/material.dart';
import 'ControlPage.dart'; // Make sure this import points to your ControlPage correctly

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
      _socket = await Socket.connect(ip, 12345, timeout: Duration(seconds: 5));
      // Instead of closing the socket, you keep it open and pass it to the next page
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ControlPage(
                socket: _socket!, ip: ip)), // Pass the socket to ControlPage
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect to Server'),
        backgroundColor: Colors.white, // Customizing AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adding padding around the body
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _ipController,
                decoration: InputDecoration(
                  hintText: 'Enter IP Address',
                  border:
                      OutlineInputBorder(), // Adding border to the TextField
                  filled: true, // Adding fill color
                  fillColor: Colors.grey[200], // Customizing fill color
                ),
              ),
              SizedBox(
                  height: 20), // Adding space between the text field and button
              ElevatedButton(
                onPressed: _checkAndNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Customizing button color
                  padding: EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20), // Customizing button padding
                ),
                child: Text('Check Availability and Connect'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
