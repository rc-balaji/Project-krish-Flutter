import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Improved Speech Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    setState(() {
      _isListening = true;
      _lastWords = ''; // Clear previous text on start
    });
    await _speechToText.listen(onResult: _onSpeechResult);
  }

  void _stopListening() async {
    setState(() {
      _isListening = false;
    });
    await _speechToText.stop();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Improved Speech Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Recognized words:',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  _lastWords,
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
            // GestureDetector for handling long press and press up
            GestureDetector(
              onLongPress: _startListening,
              onLongPressUp: _stopListening,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue, // Button color
                  borderRadius: BorderRadius.circular(100), // Rounded button
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(_isListening ? Icons.mic_off : Icons.mic,
                        color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      _isListening ? 'Stop Listening' : 'Start Listening',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
