import 'package:flutter/material.dart';
import '../models/network_configuration.dart';

class NetworkList extends StatelessWidget {
  final List<NetworkConfiguration> networkConfigs;
  final Function(NetworkConfiguration, int?) onEdit;
  final Function(NetworkConfiguration) onInfo;
  final Function(int) onDelete;
  final Function(NetworkConfiguration) onConnect;

  NetworkList({
    required this.networkConfigs,
    required this.onEdit,
    required this.onInfo,
    required this.onDelete,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return networkConfigs.length == 0
        ? Center(
            child: Text(
              'No Items Found',
              style: TextStyle(color: const Color.fromARGB(255, 255, 0, 0), fontSize: 18),
            ),
          )
        : ListView.builder(
            itemCount: networkConfigs.length,
            itemBuilder: (context, index) {
              var config = networkConfigs[index];
              return Card(
                elevation: 4.0,
                margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFED1F21), Color(0xFFB51719)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    subtitle: Text(
                      'Type: ${config.type}',
                      style: TextStyle(color: Colors.white),
                    ),
                    title: Text(
                      "${index + 1}. ${config.name}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: () => onEdit(config, index),
                        ),
                        IconButton(
                          icon: Icon(Icons.info_outline, color: Colors.white),
                          onPressed: () => onInfo(config),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.white),
                          onPressed: () => onDelete(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.link, color: Colors.white),
                          onPressed: () => onConnect(config),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
