import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DroneControlPage extends StatefulWidget {
  final Socket socket;
  final String ip;

  DroneControlPage({required this.socket, required this.ip});

  @override
  _DroneControlPageState createState() => _DroneControlPageState();
}

class _DroneControlPageState extends State<DroneControlPage> {
  void _sendMessage(String message) {
    if (widget.socket != null && message.isNotEmpty) {
      widget.socket.add(utf8.encode(message));
      widget.socket.flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the orientation is portrait
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text('Drone Controls'),
        backgroundColor: Color.fromARGB(255, 23, 160, 229),
        actions: [
          IconButton(
            icon: Icon(Icons.power_settings_new, color: Colors.red),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: OrientationBuilder(
            builder: (context, orientation) {
              return Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width),
                      child: IntrinsicHeight(
                        child: isPortrait
                            ? SizedBox()
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _controlSet(widget.socket, context,
                                      "1"), // Left controls
                                  VerticalDivider(
                                      width: 30,
                                      color: Colors.grey), // Visual separation
                                  _controlSet(widget.socket, context,
                                      "2"), // Right controls
                                ],
                              ),
                      ),
                    ),
                  ),
                  // Display the text only in portrait mode
                  if (isPortrait)
                    Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 3,
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Turn your screen for a better experience',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _controlSet(Socket socket, BuildContext context, String controlSetId) {
    double buttonSize = MediaQuery.of(context).size.width / 24;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _controlButton(
            Icons.arrow_upward, 'F' + controlSetId, 'Forward', buttonSize),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _controlButton(
                Icons.arrow_back, 'L' + controlSetId, 'Left', buttonSize),
            SizedBox(width: buttonSize / 4),
            _controlButton(Icons.stop, 'S' + controlSetId, 'Stop', buttonSize),
            SizedBox(width: buttonSize / 4),
            _controlButton(
                Icons.arrow_forward, 'R' + controlSetId, 'Right', buttonSize),
          ],
        ),
        _controlButton(
            Icons.arrow_downward, 'B' + controlSetId, 'Back', buttonSize),
      ],
    );
  }

  Widget _controlButton(
      IconData icon, String command, String tooltip, double size) {
    return Padding(
      padding: const EdgeInsets.all(8.0), // Add padding around each button
      child: Tooltip(
        message: tooltip,
        child: Ink(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 232, 8, 8),
            shape: BoxShape.circle,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(1000),
            onTap: () => _sendMessage(command),
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Icon(
                icon,
                size: size,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
