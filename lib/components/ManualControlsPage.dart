import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';


class ManualControlsPage extends StatefulWidget {
  final Socket socket;
  final String ip;

  ManualControlsPage({required this.socket, required this.ip});

  @override
  _ManualControlsPageState createState() => _ManualControlsPageState();
}

class _ManualControlsPageState extends State<ManualControlsPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual Controls'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.power_settings_new, color: Colors.red),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        backgroundColor: Color.fromARGB(255, 23, 160, 229),
      ),
      body: Joystick(onDirectionChanged: _sendMessage),
    );
  }
}

class Joystick extends StatefulWidget {
  final Function(String) onDirectionChanged;

  Joystick({required this.onDirectionChanged});

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (details) {
            _startSendingDirections();
          },
          onPanUpdate: (details) {
            _updatePosition(details.localPosition, constraints.biggest);
          },
          onPanEnd: (details) {
            setState(() {
              _x = 0;
              _y = 0;
            });
            _stopMovement();
          },
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: JoystickPainter(_x, _y),
          ),
        );
      },
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

    canvas.drawCircle(
        Offset(size.width / 2 + x, size.height / 2 + y), size.width / 8, innerPaint);
  }

  @override
  bool shouldRepaint(JoystickPainter oldDelegate) {
    return oldDelegate.x != x || oldDelegate.y != y;
  }
}
