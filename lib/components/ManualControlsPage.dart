import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class ManualControlsPage extends StatefulWidget {
  final Socket socket;
  final String ip;

  ManualControlsPage({required this.socket, required this.ip});

  @override
  _ManualControlsPageState createState() => _ManualControlsPageState();
}

class _ManualControlsPageState extends State<ManualControlsPage> {
  void _sendMessage(String message) {
    if (widget.socket != null && message.isNotEmpty) {
      widget.socket.add(utf8.encode(message));
      widget.socket.flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    double buttonSize =
        MediaQuery.of(context).size.width / 7; // Responsive button size
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual Controls'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.power_settings_new, color: Colors.red),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        backgroundColor:
            Color.fromARGB(255, 23, 160, 229), // Consistent theming
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _controlButton(Icons.arrow_upward, 'F', 'Forward', buttonSize),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _controlButton(Icons.arrow_back, 'L', 'Left', buttonSize),
                SizedBox(width: buttonSize / 2), // Responsive spacing
                _controlButton(Icons.stop, 'S', 'Stop', buttonSize),
                SizedBox(width: buttonSize / 2), // Responsive spacing
                _controlButton(Icons.arrow_forward, 'R', 'Right', buttonSize),
              ],
            ),
            _controlButton(Icons.arrow_downward, 'B', 'Back', buttonSize),
          ],
        ),
      ),
    );
  }

  Widget _controlButton(
      IconData icon, String command, String tooltip, double size) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Ink(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 173, 41, 41), // Button color
          shape: BoxShape.circle,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(1000), // Circular effect
          onTap: () => _sendMessage(command),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Icon(
              icon,
              size: size,
              color: Colors.white, // Icon color for better contrast
            ),
          ),
        ),
      ),
    );
  }
}
