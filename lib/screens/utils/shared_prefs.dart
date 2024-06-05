import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/network_configuration.dart';

class SharedPrefs {
  static Future<void> saveNetworkConfigs(
      List<NetworkConfiguration> networkConfigs) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String configsString =
        json.encode(networkConfigs.map((config) => config.toJson()).toList());
    await prefs.setString('networkConfigs', configsString);
  }

  static Future<List<NetworkConfiguration>> loadNetworkConfigs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? configsString = prefs.getString('networkConfigs');
    if (configsString != null) {
      final List<dynamic> jsonDecoded = json.decode(configsString);
      return jsonDecoded
          .map((config) => NetworkConfiguration.fromJson(config))
          .toList();
    } else {
      return [];
    }
  }
}
