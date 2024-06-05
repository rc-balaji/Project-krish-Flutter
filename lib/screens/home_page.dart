import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_first_app/screens/widgets/floating_widgets.dart';
import 'models/network_configuration.dart';
import '../pages/ControlPage.dart';
import '../pages/stream_page.dart';
import 'utils/shared_prefs.dart';
import 'widgets/network_list.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

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
    networkConfigs = await SharedPrefs.loadNetworkConfigs();
    setState(() {});
  }

  Future<void> _saveNetworkConfigs() async {
    await SharedPrefs.saveNetworkConfigs(networkConfigs);
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

  void _addOrEditNetwork({NetworkConfiguration? config, int? index}) {
    TextEditingController nameController =
        TextEditingController(text: config?.name ?? '');
    TextEditingController ipController =
        TextEditingController(text: config?.ipAddress ?? '');
    String wifiName = _currentWiFi;
    String selectedType = config?.type ?? 'Node';

    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(config == null ? 'Add Network' : 'Edit Network'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: ipController,
                    decoration: InputDecoration(labelText: "IP Address"),
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
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text('Save'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        });
      },
    ).then((confirmed) {
      if (confirmed == true) {
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
    });
  }

  Future<void> _showNetworkInfo(NetworkConfiguration config) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Network Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Name: ${config.name}'),
                Text('Type: ${config.type}'),
                Text('IP Address: ${config.ipAddress}'),
                Text('WiFi Name: ${config.wifiName}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
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
            child: CircularProgressIndicator(),
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _addOrEditNetwork(),
            ),
          ],
        ),
        body: Column(
          children: [
            FloatingWidget(
                wifiEnabled: _wifiEnabled,
                locationEnabled: _locationEnabled,
                currentWiFi: _currentWiFi),
            Expanded(
              child: NetworkList(
                networkConfigs: networkConfigs,
                onEdit: (config, index) =>
                    _addOrEditNetwork(config: config, index: index),
                onInfo: _showNetworkInfo,
                onDelete: _deleteNetwork,
                onConnect: _connectToNetwork,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
