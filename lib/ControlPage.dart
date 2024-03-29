import 'dart:io';
import 'package:flutter/material.dart';
import 'components/VoicePage.dart';
import 'components/ManualControlsPage.dart';

class ControlPage extends StatefulWidget {
  final Socket socket;
  final String ip;

  ControlPage({required this.socket, required this.ip});

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  int _currentIndex = 0;
  late List<Widget> _children;

  @override
  void initState() {
    super.initState();
    // Initialize _children here, passing both socket and ip to the pages
    _children = [
      VoicePage(socket: widget.socket, ip: widget.ip),
      ManualControlsPage(socket: widget.socket, ip: widget.ip),
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Voice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.touch_app),
            label: 'Manual',
          ),
        ],
      ),
    );
  }
}
