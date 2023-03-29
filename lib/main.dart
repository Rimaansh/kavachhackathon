import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'My App',
      home: MyHomePage(title: 'Women\'s Safety App',),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and say "help" to make an emergency call.';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _makeEmergencyCall() async {
    const String phoneNumber = 'tel:911';
    if (await Permission.phone.request().isGranted) {
      if (await canLaunch(phoneNumber)) {
        await launch(phoneNumber);
      } else {
        throw 'Could not launch $phoneNumber';
      }
    } else {
      throw 'Permission to access the phone is not granted.';
    }
  }


  void startListening() {
    _isListening = true;
    _speech.listen(
      onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
        });
        if (_text.toLowerCase() == 'help') {
          _makeEmergencyCall();
        }
      },
    );
    setState(() {
      _isListening = true;
    });
  }

  void stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      backgroundColor: Colors.blueGrey[400],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isListening) {
            stopListening();
          } else {
            startListening();
          }
        },
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _text,
              style: TextStyle(fontSize: 32, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
