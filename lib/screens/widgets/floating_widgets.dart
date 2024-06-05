import 'package:flutter/material.dart';

class FloatingWidget extends StatelessWidget {
  final bool wifiEnabled;
  final bool locationEnabled;
  final String currentWiFi;

  const FloatingWidget({
    required this.wifiEnabled,
    required this.locationEnabled,
    required this.currentWiFi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingIndicators(
            axisData: {
              "topLeft": 0.0,
              "bottomLeft": 0.0,
              "topRight": 50.0,
              "bottomRight": 50.0,
            },
            indicators: [
              IndicatorData(
                icon: Icons.wifi,
                isOn: wifiEnabled,
                message: wifiEnabled ? "WiFi is on" : "WiFi is off",
              ),
              IndicatorData(
                icon: Icons.location_on,
                isOn: locationEnabled,
                message: locationEnabled ? "Location is on" : "Location is off",
              ),
            ],
          ),
          FloatingIndicators(
            axisData: {
              "topLeft": 50.0,
              "bottomLeft": 50.0,
              "topRight": 0.0,
              "bottomRight": 0.0,
            },
            indicators: [
              IndicatorData(
                icon: Icons.phone_android_rounded,
                isOn: wifiEnabled && currentWiFi != "Not Connected",
                message: wifiEnabled && currentWiFi != "Not Connected"
                    ? "Connected to $currentWiFi"
                    : currentWiFi,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// The rest of your code remains unchanged

class FloatingIndicators extends StatelessWidget {
  final List<IndicatorData> indicators;
  final Map<String, double> axisData;

  const FloatingIndicators({
    required this.indicators,
    required this.axisData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(axisData["topLeft"] ?? 0.0),
          bottomLeft: Radius.circular(axisData["bottomLeft"] ?? 0.0),
          topRight: Radius.circular(axisData["topRight"] ?? 0.0),
          bottomRight: Radius.circular(axisData["bottomRight"] ?? 0.0),
        ),
        color: const Color.fromARGB(255, 136, 131, 131),
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: indicators.map((data) {
          return Row(
            children: [
              IndicatorButton(
                icon: data.icon,
                isOn: data.isOn,
                message: data.message,
              ),
              SizedBox(width: 15), // Adjust the width as needed
            ],
          );
        }).toList(),
      ),
    );
  }
}

class IndicatorButton extends StatelessWidget {
  final IconData icon;
  final bool isOn;
  final String message;

  const IndicatorButton({
    required this.icon,
    required this.isOn,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: 37.0,
          height: 37.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: isOn ? Colors.green : const Color.fromARGB(255, 0, 0, 0),
          ),
          child: Center(
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 255, 255, 255),
              size: 25.0,
            ),
          ),
        ),
      ),
    );
  }
}

class IndicatorData {
  final IconData icon;
  final bool isOn;
  final String message;

  IndicatorData({
    required this.icon,
    required this.isOn,
    required this.message,
  });
}
