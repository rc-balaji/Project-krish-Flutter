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
    return ListView.builder(
      itemCount: networkConfigs.length,
      itemBuilder: (context, index) {
        var config = networkConfigs[index];
        return Card(
          elevation: 4.0,
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            contentPadding: EdgeInsets.all(16.0),
            subtitle: Text('Type: ${config.type}'),
            title: Text(
              "${index + 1}. ${config.name}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => onEdit(config, index),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () => onInfo(config),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () => onDelete(index),
                ),
                IconButton(
                  icon: Icon(Icons.link),
                  onPressed: () => onConnect(config),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
