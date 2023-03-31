import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class HelpPanel extends StatefulWidget {
  @override
  _HelpPanelState createState() => _HelpPanelState();
}

class _HelpPanelState extends State<HelpPanel> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and say "help" to make an emergency call.';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    initSpeechToText();
  }

  Future<void> initSpeechToText() async {
    await _speech.initialize();
  }

  Future<void> _makeEmergencyCall() async {
    const phoneNumber = '+917004939484';
    if (await Permission.phone.request().isGranted) {
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    } else {
      await Permission.phone.request();
      if (await Permission.phone.isGranted) {
        await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      } else {
        throw 'Permission to access the phone is not granted.';
      }
    }
  }

  bool containsHelp(String str) {
    return str.toLowerCase().contains('help');
  }

  void startListening() {
    _isListening = true;
    _speech.listen(
      onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
          print(_text);
        });
        if (containsHelp(_text) == true) {
          print(containsHelp(_text));
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _text,
            style: TextStyle(fontSize: 32, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30.0),
          GestureDetector(
            onTapDown: (details) {
              startListening();
            },
            onTapUp: (details) {
              stopListening();
            },
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(50.0),
              color: Colors.blue,
              child: SizedBox(
                width: 70.0,
                height: 70.0,
                child: Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 40.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
