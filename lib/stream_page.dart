import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class StreamPage extends StatefulWidget {
  final String ip;

  StreamPage({required this.ip});

  @override
  _StreamPageState createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  late String streamUrl;

  @override
  void initState() {
    super.initState();
    streamUrl = 'http://${widget.ip}:81/stream';
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Mjpeg(
                isLive: true,
                stream: streamUrl,
                error: (context, error, stack) {
                  return Center(
                    child: Text(
                      'Failed to load the stream',
                      style: TextStyle(fontSize: 20, color: Colors.redAccent),
                    ),
                  );
                },
                timeout: const Duration(seconds: 5),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.redAccent,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.stop, color: Colors.white, size: 30),
                elevation: 8,
                tooltip: 'Stop Stream',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
