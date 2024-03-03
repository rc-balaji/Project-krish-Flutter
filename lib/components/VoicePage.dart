import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoicePage extends StatefulWidget {
  final Socket socket; // Change to accept a Socket instance
  final String ip;

  VoicePage({required this.socket, required this.ip});

  @override
  _VoicePageState createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  String _displayedText = ''; // Add this line

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
      _lastWords = ''; // Clear the last recognized words at the start
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
    // Update the last recognized words and displayed text with the current result
    setState(() {
      _lastWords = result.recognizedWords;
      _displayedText = _lastWords;
      // print(_displayedText);
      _processCommand(_displayedText.trim()); // Update the displayed text
    });
  }

  void _processCommand(String command) {
    command = command.toLowerCase();
    if (command.contains('forward')) {
      _sendMessage('forward');
    } else if (command.contains('back')) {
      _sendMessage('back');
    } else if (command.contains('stop')) {
      _sendMessage('stop');
    } else if (command.contains('left')) {
      _sendMessage('left');
    } else if (command.contains('right')) {
      _sendMessage('right');
    } else {
      print("Unknown Commends");
    }
  }

  void _showUnknownCommandDialog(String command) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unknown Command'),
          content: Text('Received unknown command: $command'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the alert dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _sendMessage(String message) {
    if (widget.socket != null && message.isNotEmpty) {
      widget.socket!.add(utf8.encode(message));
      widget.socket!.flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Controls'),
        actions: [
          IconButton(
            icon: Icon(Icons.power_settings_new, color: Colors.red),
            onPressed: () {
              widget.socket?.close();
              Navigator.pop(
                  context); // Adjusted to simply pop back without disconnecting
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Say a command to control the light:',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          Text(
            _isListening
                ? 'Listening...'
                : 'Press & Hold the button below to speak',
            style: TextStyle(fontSize: 16.0, color: Colors.blue),
          ),
          SizedBox(height: 20), // Add some spacing
          // Display the recognized command
          Text(
            _displayedText, // Display the last recognized words here
            style: TextStyle(fontSize: 24.0, color: Colors.black),
          ),
          SizedBox(height: 20), // Add some spacing
          GestureDetector(
            onLongPress: _startListening,
            onLongPressUp: _stopListening,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(100),
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
          SizedBox(height: 20), // Add some spacing
          // // ElevatedButton(
          //   onPressed: _disconnect,
          //   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          //   child: Text('Disconnect'),
          // ),
        ],
      ),
    );
  }
}
