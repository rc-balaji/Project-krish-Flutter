import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class DroneControlPage extends StatefulWidget {
  final Socket socket;
  final String ip;

  DroneControlPage({required this.socket, required this.ip});

  @override
  _DroneControlPageState createState() => _DroneControlPageState();
}

class _DroneControlPageState extends State<DroneControlPage> {
  Socket? _socket;

  @override
  void initState() {
    super.initState();
    setState(() {
      _socket = widget.socket;
    });
  }

  void _sendMessage(String message) {
    if (_socket != null && message.isNotEmpty) {
      _socket!.add(utf8.encode(message));
      _socket!.flush();
    }
  }

  @override
  void dispose() {
    _socket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text('Drone Controls'),
        backgroundColor: Color.fromRGBO(212, 22, 26, 1),
        actions: [
          IconButton(
            icon: Icon(Icons.power_settings_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(255, 255, 255, 0.8),
              Color.fromRGBO(255, 255, 255, 0.8)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          child: SafeArea(
            child: isPortrait
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Turn your screen for a better experience',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: const Color.fromARGB(255, 255, 0, 0),
                        ),
                      ),
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height *
                        0.8, 
                    child: Stack(
                      children: [
                        Positioned(
                          top: -230,
                          right: -50,
                          child: Transform.rotate(
                            angle: 0 * 3.1415926535897932 / 180,
                            child: Opacity(
                              opacity: 0.38,
                              child: Image.asset(
                                'assets/images/control.png',
                                width: 850,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 40,
                          top: 8 ,
                          child: Joystick(
                            onDirectionChanged: (direction) =>
                                _sendMessage('L' + direction),
                            label: 'Left',
                            size: 230,
                            rotation: 0.0,
                          ),
                        ),
                        Positioned(
                          right: 68 ,
                          top: 8 ,
                          child: Joystick(
                            onDirectionChanged: (direction) =>
                                _sendMessage('R' + direction),
                            label: 'Right',
                            size: 230,
                            rotation: 0.0,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class Joystick extends StatefulWidget {
  final Function(String) onDirectionChanged;
  final String label;
  final double size;
  final double rotation;

  Joystick(
      {required this.onDirectionChanged,
      required this.label,
      this.size = 150,
      this.rotation = 0.0});

  @override
  _JoystickState createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  double _x = 0;
  double _y = 0;
  String _currentDirection = '';
  Timer? _timer;

  void _startSendingDirections() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_currentDirection.isNotEmpty) {
        widget.onDirectionChanged(_currentDirection);
      }
    });
  }

  void _updatePosition(Offset offset, Size size) {
    double radius = size.width / 4;
    setState(() {
      _x = offset.dx - size.width / 2;
      _y = offset.dy - size.height / 2;
      double distance = sqrt(_x * _x + _y * _y);

      if (distance > radius) {
        _x = (_x / distance) * radius;
        _y = (_y / distance) * radius;
      }
    });

    double angle = (atan2(_y, _x) * 180 / pi + 360) % 360;
    String newDirection = "STOP";
    if (angle >= 315 || angle < 45) {
      newDirection = 'R';
    } else if (angle >= 45 && angle < 135) {
      newDirection = 'B';
    } else if (angle >= 135 && angle < 225) {
      newDirection = 'L';
    } else if (angle >= 225 && angle < 315) {
      newDirection = 'F';
    }

    if (newDirection != _currentDirection) {
      _currentDirection = newDirection;
      _startSendingDirections();
    }
  }

  void _stopMovement() {
    _currentDirection = '';
    _timer?.cancel();
    widget.onDirectionChanged('STOP');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: Column(
        children: [
          Text(
            widget.label,
            style: TextStyle(
                fontSize: 20, color: const Color.fromARGB(255, 0, 0, 0)),
          ),
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                _startSendingDirections();
              },
              onPanUpdate: (details) {
                _updatePosition(
                    details.localPosition, Size(widget.size, widget.size));
              },
              onPanEnd: (details) {
                setState(() {
                  _x = 0;
                  _y = 0;
                });
                _stopMovement();
              },
              child: Transform.rotate(
                angle: widget.rotation,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: JoystickPainter(_x, _y),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JoystickPainter extends CustomPainter {
  final double x;
  final double y;

  JoystickPainter(this.x, this.y);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    final Paint innerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 4, paint);

    canvas.drawCircle(Offset(size.width / 2 + x, size.height / 2 + y),
        size.width / 8, innerPaint);
  }

  @override
  bool shouldRepaint(JoystickPainter oldDelegate) {
    return oldDelegate.x != x || oldDelegate.y != y;
  }
}
