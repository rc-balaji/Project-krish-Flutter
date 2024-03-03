import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class ManualControlsPage extends StatefulWidget {
  final Socket socket; // Change to accept a Socket instance
  final String ip;

  ManualControlsPage({required this.socket, required this.ip});

  @override
  _ManualControlsPageState createState() => _ManualControlsPageState();
}

class _ManualControlsPageState extends State<ManualControlsPage> {
  // Remove the socket variable and the _connect and _disconnect methods
  // as the socket management is handled outside of this page now.

  void _sendMessage(String message) {
    if (widget.socket != null && message.isNotEmpty) {
      widget.socket.add(utf8.encode(message));
      widget.socket.flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual Controls'),
        actions: [
          IconButton(
            icon: Icon(Icons.power_settings_new, color: Colors.red),
            onPressed: () {
              widget.socket?.close();
              Navigator.pop(
                  context); // Adjusted to simply pop back without disconnecting
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _controlButton(Icons.arrow_upward, 'F', 'Forward'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _controlButton(Icons.arrow_back, 'L', 'Left'),
                SizedBox(width: 20),
                _controlButton(Icons.stop, 'S', 'Stop'),
                SizedBox(width: 20),
                _controlButton(Icons.arrow_forward, 'R', 'Right'),
              ],
            ),
            _controlButton(Icons.arrow_downward, 'B', 'Back'),
          ],
        ),
      ),
    );
  }

  Widget _controlButton(IconData icon, String command, String tooltip) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FloatingActionButton(
        onPressed: () => _sendMessage(command),
        tooltip: tooltip,
        child: Icon(icon),
      ),
    );
  }

  // No need to override dispose to close the socket as it's managed outside
}
