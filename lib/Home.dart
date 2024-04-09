import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ControlPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _ipController = TextEditingController();
  Socket? _socket;
  String _wifiName = 'Not Connected';
  bool _wifiEnabled = false;
  bool _locationEnabled = false;
  final Location location = Location();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initNetworkInfo();
    _startMonitoring();
    _requestPermissions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initNetworkInfo() async {
    bool wifiEnabled = await WiFiForIoTPlugin.isEnabled();
    bool locationEnabled = await location.serviceEnabled();
    String wifiName = await WiFiForIoTPlugin.getSSID() ?? 'Not Connected';

    if (wifiEnabled != _wifiEnabled ||
        locationEnabled != _locationEnabled ||
        wifiName != _wifiName) {
      setState(() {
        _wifiEnabled = wifiEnabled;
        _locationEnabled = locationEnabled;
        _wifiName = wifiName;
      });
    }
  }

  void _startMonitoring() {
    _timer?.cancel();
    _timer =
        Timer.periodic(Duration(seconds: 10), (Timer t) => _initNetworkInfo());
  }

  Future<void> _requestPermissions() async {
    await Permission.location.request();
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  void _checkAndNavigate() async {
    String ip = _ipController.text;
    try {
      _socket = await Socket.connect(ip, 80, timeout: Duration(seconds: 5));
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ControlPage(socket: _socket!, ip: ip)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not connect to the server: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                if (!_wifiEnabled)
                  Text('WiFi is OFF', style: TextStyle(color: Colors.red)),
                if (!_locationEnabled)
                  Text('Location is OFF', style: TextStyle(color: Colors.red)),
                Text('Connected WiFi: $_wifiName'),
                SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset('assets/images/logo.png',
                      width: size.width * 0.6,
                      height: size.height * 0.3,
                      fit: BoxFit.contain),
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
