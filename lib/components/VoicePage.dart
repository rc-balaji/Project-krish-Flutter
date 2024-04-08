import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoicePage extends StatefulWidget {
  final Socket socket;
  final String ip;

  VoicePage({required this.socket, required this.ip});

  @override
  _VoicePageState createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _displayedText = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    setState(() {
      _isListening = true;
      _displayedText = ''; // Reset displayed text
    });
    await _speechToText.listen(onResult: _onSpeechResult);
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _displayedText = result.recognizedWords;
      _processCommand(_displayedText.trim());
    });
  }

  void _processCommand(String command) {
    command = command.toLowerCase();
    if (command.contains('forward')) {
      _sendMessage('F');
    } else if (command.contains('back')) {
      _sendMessage('B');
    } else if (command.contains('stop')) {
      _sendMessage('S');
    } else if (command.contains('left')) {
      _sendMessage('L');
    } else if (command.contains('right')) {
      _sendMessage('R');
    } else {
      print("Unknown Commends");
    }
  }

  void _showUnknownCommandDialog(String command) {
    // Shows a dialog for unknown commands
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unknown Command'),
          content: Text('Received unknown command: $command'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _sendMessage(String message) {
    if (widget.socket != null && message.isNotEmpty) {
      widget.socket.add(utf8.encode(message));
      widget.socket.flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Controls'),
        backgroundColor: Color.fromARGB(255, 23, 160, 229),
        actions: [
          IconButton(
            icon: Icon(Icons.power_settings_new, color: Colors.red),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Say a command:',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text(
                  _isListening ? 'Listening...' : 'Tap the mic to start',
                  style: TextStyle(
                      fontSize: 18.0, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _displayedText,
                  style: TextStyle(fontSize: 20.0),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              FloatingActionButton(
                onPressed: _isListening ? _stopListening : _startListening,
                child: Icon(_isListening ? Icons.mic_off : Icons.mic),
                backgroundColor: _isListening ? Colors.red : Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
