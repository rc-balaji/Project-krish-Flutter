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
        'type': type,
      };

  factory NetworkConfiguration.fromJson(Map<String, dynamic> jsonData) {
    return NetworkConfiguration(
      name: jsonData['name'],
      ipAddress: jsonData['ipAddress'],
      wifiName: jsonData['wifiName'],
      type: jsonData['type'],
    );
  }
}
