import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rapdle/screen/lose_screen.dart';
import 'package:rapdle/screen/win_screen.dart';
import 'package:rapdle/widgets/responsive.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rapdle/screen/home_page.dart';
import 'package:lottie/lottie.dart';

class GuessTheSong extends StatefulWidget {
  const GuessTheSong({Key? key, required this.screenSize, required this.onLose})
      : super(key: key);

  final Size screenSize;
  final Function(bool) onLose;

  @override
  _GuessTheSongState createState() => _GuessTheSongState();
}

class _GuessTheSongState extends State<GuessTheSong>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();
  String _currentSongName = "";
  String _message = "";
  int _attempts = 0;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
  }

  @override
  void dispose() {
    _textController.dispose();
    audioPlayer.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> playSong(String filePath, String songName) async {
    try {
      final url = await FirebaseStorage.instance.ref(filePath).getDownloadURL();
      await audioPlayer.play(UrlSource(url));
      Timer(Duration(seconds: _attempts + 1), () async {
        await audioPlayer.stop();
      });
      setState(() {
        _currentSongName = songName;
        _message = "";
      });
      // Uruchomienie animacji
      _animationController!.duration = Duration(seconds: _attempts + 1);
      _animationController!
          .forward()
          .whenComplete(() => _animationController!.reset());
    } catch (e) {
      print('Wystąpił błąd podczas odtwarzania piosenki: $e');
    }
  }

  void _checkAnswer() {
    if (_textController.text.trim().toLowerCase() ==
        _currentSongName.toLowerCase()) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => WinScreen(
                songName: _currentSongName,
                imagePath: 'path/to/your/image',
                onRetry: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              )));
    } else {
      setState(() {
        _attempts++;
        if (_attempts >= 5) {
          widget.onLose(true);
        } else {
          _message = "Spróbuj jeszcze raz!";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: Padding(
        padding: EdgeInsets.only(
          top: widget.screenSize.height * 0.60,
          left: ResponsiveWidget.isSmallScreen(context)
              ? widget.screenSize.width / 5
              : widget.screenSize.width / 5,
          right: ResponsiveWidget.isSmallScreen(context)
              ? widget.screenSize.width / 5
              : widget.screenSize.width / 5,
        ),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('PlayAnimation.json',
                    width: 250, height: 250, controller: _animationController),
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: "Wpisz nazwę piosenki...",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                Text(_message),
                Text('Ilość prób: $_attempts'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () =>
                          playSong('Young Leosia, bambi- PGS.mp3', 'PGS'),
                    ),
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: _checkAnswer,
                    ),
                    IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: () {
                        audioPlayer.pause();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
