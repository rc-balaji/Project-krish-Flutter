import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_first_app/stream_page.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ControlPage.dart';
import 'WebcamPage.dart';

class NetworkConfiguration {
  String name;
  String ipAddress;
  String wifiName;
  String type;

  NetworkConfiguration({
    required this.name,
    required this.ipAddress,
    required this.wifiName,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'ipAddress': ipAddress,
        'wifiName': wifiName,
        'type': type
      };

  factory NetworkConfiguration.fromJson(Map<String, dynamic> jsonData) {
    return NetworkConfiguration(
        name: jsonData['name'],
        ipAddress: jsonData['ipAddress'],
        wifiName: jsonData['wifiName'],
        type: jsonData['type']);
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<NetworkConfiguration> networkConfigs = [];
  String _currentWiFi = 'Not Connected';
  bool _wifiEnabled = false;
  bool _locationEnabled = false;
  final Location location = Location();

  @override
  void initState() {
    super.initState();
    _loadNetworkConfigs();
    _requestPermissions();
    _initNetworkInfo();
    _startMonitoring();
  }

  Future<void> _loadNetworkConfigs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? configsString = prefs.getString('networkConfigs');
    if (configsString != null) {
      final List<dynamic> jsonDecoded = json.decode(configsString);
      networkConfigs = jsonDecoded
          .map((config) => NetworkConfiguration.fromJson(config))
          .toList();
      setState(() {});
    }
  }

  Future<void> _saveNetworkConfigs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String configsString = json.encode(networkConfigs);
    await prefs.setString('networkConfigs', configsString);
  }

  Future<void> _initNetworkInfo() async {
    _wifiEnabled = await WiFiForIoTPlugin.isEnabled();
    _locationEnabled = await location.serviceEnabled();
    _currentWiFi = await WiFiForIoTPlugin.getSSID() ?? 'Not Connected';
    setState(() {});
  }

  void _startMonitoring() {
    Timer.periodic(Duration(seconds: 10), (Timer t) => _initNetworkInfo());
  }

  Future<void> _requestPermissions() async {
    await [Permission.location, Permission.microphone, Permission.storage]
        .request();
  }

  Future<void> _addOrEditNetwork(
      {NetworkConfiguration? config, int? index}) async {
    TextEditingController nameController =
        TextEditingController(text: config?.name ?? '');
    TextEditingController ipController =
        TextEditingController(text: config?.ipAddress ?? '');
    String wifiName = _currentWiFi;
    String selectedType = config?.type ?? 'Node';

    bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  config == null ? 'Add Network' : 'Edit Network',
                  style: TextStyle(color: Color.fromARGB(255, 23, 160, 229)),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Name",
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 23, 160, 229)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 23, 160, 229)),
                          ),
                        ),
                      ),
                      TextField(
                        controller: ipController,
                        decoration: InputDecoration(
                          labelText: "IP Address",
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 23, 160, 229)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 23, 160, 229)),
                          ),
                        ),
                      ),
                      DropdownButton<String>(
                        value: selectedType,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedType = newValue;
                            });
                          }
                        },
                        items: <String>['Node', 'Cam'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: TextStyle(
                                    color: Color.fromARGB(255, 23, 160, 229))),
                          );
                        }).toList(),
                        style: TextStyle(
                            color: Color.fromARGB(255, 23, 160, 229),
                            fontSize: 16),
                        dropdownColor: Colors.white,
                        underline: Container(
                          height: 2,
                          color: Color.fromARGB(255, 23, 160, 229),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel',
                        style: TextStyle(
                            color: Color.fromARGB(255, 23, 160, 229))),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    child: Text('Save',
                        style: TextStyle(
                            color: Color.fromARGB(255, 23, 160, 229))),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
            });
          },
        ) ??
        false;

    if (confirmed) {
      setState(() {
        if (index == null) {
          networkConfigs.add(NetworkConfiguration(
            name: nameController.text,
            ipAddress: ipController.text,
            wifiName: wifiName,
            type: selectedType,
          ));
        } else {
          networkConfigs[index] = NetworkConfiguration(
            name: nameController.text,
            ipAddress: ipController.text,
            wifiName: wifiName,
            type: selectedType,
          );
        }
      });
      _saveNetworkConfigs();
    }
  }

  Future<void> _showNetworkInfo(NetworkConfiguration config) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Network Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 23, 160, 229),
            ),
          ),
          content: SingleChildScrollView(
            // Making content scrollable for responsiveness
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Name: ${config.name}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Type: ${config.type}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'IP Address: ${config.ipAddress}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'WiFi Name: ${config.wifiName}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(
                  color: Color.fromARGB(255, 23, 160, 229),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _connectToNetwork(NetworkConfiguration config) async {
    if (config.wifiName == _currentWiFi) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 23, 160, 229),
            ),
          );
        },
      );

      try {
        if (config.type == 'Node') {
          Socket socket = await Socket.connect(config.ipAddress, 80,
              timeout: Duration(seconds: 5));
          Navigator.pop(context);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ControlPage(socket: socket, ip: config.ipAddress),
            ),
          );
        } else if (config.type == 'Cam') {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StreamPage(ip: config.ipAddress),
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Connection Error"),
            content: Text(
                "Failed to connect to ${config.name} at ${config.ipAddress}. Error: $e"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK")),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("WiFi Mismatch"),
          content: Text(
              "Please connect to the WiFi network '${config.wifiName}' to proceed."),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK")),
          ],
        ),
      );
    }
  }

  void _deleteNetwork(int index) {
    setState(() {
      networkConfigs.removeAt(index);
    });
    _saveNetworkConfigs();
  }

  Widget _buildNetworkList() {
    return ListView.builder(
      itemCount: networkConfigs.length,
      itemBuilder: (context, index) {
        var config = networkConfigs[index];
        return Card(
          elevation: 4.0,
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            contentPadding: EdgeInsets.all(16.0),
            subtitle: Text('Type : ${config.type}'),
            title: Text(
              "${index + 1}. ${config.name}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _iconButton(Icons.edit,
                    () => _addOrEditNetwork(config: config, index: index)),
                _iconButton(Icons.info_outline, () => _showNetworkInfo(config)),
                _iconButton(Icons.delete_outline, () => _deleteNetwork(index)),
                _iconButton(Icons.link, () => _connectToNetwork(config)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Color.fromARGB(255, 23, 160, 229)),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          backgroundColor: Color.fromARGB(255, 23, 160, 229),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _addOrEditNetwork(),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: ListTile(
                tileColor: Colors.deepPurple[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Text(_wifiEnabled ? 'WiFi: ON' : 'WiFi: OFF',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle:
                    Text(_locationEnabled ? 'Location: ON' : 'Location: OFF'),
                trailing: Chip(
                  label: Text('Connected to: $_currentWiFi',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Color.fromARGB(255, 23, 160, 229),
                ),
              ),
            ),
            Expanded(child: _buildNetworkList()),
          ],
        ),
      ),
    );
  }
}
