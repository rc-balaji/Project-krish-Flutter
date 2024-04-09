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
    _children = [
      ManualControlsPage(socket: widget.socket, ip: widget.ip),
      VoicePage(socket: widget.socket, ip: widget.ip),
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
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _children,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.touch_app),
            label: 'Manual',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Voice',
          ),
        ],
        backgroundColor: Color.fromARGB(255, 23, 160, 229),
        selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
