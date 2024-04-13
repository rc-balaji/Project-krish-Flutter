import 'package:flutter/material.dart';

class WebcamPage extends StatefulWidget {
  final String ip;

  const WebcamPage({super.key, required this.ip});

  @override
  State<WebcamPage> createState() => _WebcamPageState();
}

class _WebcamPageState extends State<WebcamPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Webcam at ${widget.ip}'),
        backgroundColor: Color.fromARGB(255, 23, 160, 229),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Webcam Stream for ${widget.ip}',
              style: TextStyle(fontSize: 20, color: Colors.black54),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                // Here you might typically include a video stream.
                // This placeholder can be replaced with a video streaming widget.
                decoration: BoxDecoration(
                  color: Colors.black12,
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Center(
                  child: Text(
                    'Video Stream Placeholder',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
