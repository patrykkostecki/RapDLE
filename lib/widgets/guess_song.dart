import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rapdle/widgets/lose_screen.dart';
import 'package:rapdle/widgets/responsive.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rapdle/screen/home_page.dart';

class GuessTheSong extends StatefulWidget {
  const GuessTheSong({Key? key, required this.screenSize, required this.onLose})
      : super(key: key);

  final Size screenSize;
  final Function(bool) onLose;

  @override
  _GuessTheSongState createState() => _GuessTheSongState();
}

class _GuessTheSongState extends State<GuessTheSong> {
  final TextEditingController _textController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();
  String _currentSongName =
      ""; // Zmienna przechowująca nazwę aktualnej piosenki
  String _message = ""; // Wiadomość dla użytkownika
  int _attempts = 0;

  @override
  void dispose() {
    _textController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playSong(String filePath, String songName) async {
    try {
      final url = await FirebaseStorage.instance.ref(filePath).getDownloadURL();
      await audioPlayer.play(UrlSource(url));
      Timer(Duration(seconds: _attempts + 1), () async {
        await audioPlayer.stop(); // Zatrzymuje piosenkę po 5 sekundach
      });
      setState(() {
        _currentSongName = songName; // Aktualizacja nazwy aktualnej piosenki
        _message = ""; // Wyczyszczenie poprzedniej wiadomości
      });
    } catch (e) {
      print('Wystąpił błąd podczas odtwarzania piosenki: $e');
    }
  }

  void _checkAnswer() {
    if (_textController.text.trim().toLowerCase() ==
        _currentSongName.toLowerCase()) {
      setState(() {
        _message = "Wygrałeś!";
      });
    } else {
      setState(() {
        _attempts++;
        if (_attempts < 5) {
          _message = "Spróbuj jeszcze raz!";
        } else {
          widget.onLose(true);
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
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: "Wpisz nazwę piosenki...",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10), // Dodaje odstęp
                Text(_message),
                Text(
                    'Ilość prób:  $_attempts'), // Wyświetla wiadomość dla użytkownika
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        playSong('test.mp3',
                            'test'); // Podaj odpowiednią nazwę piosenki
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: _checkAnswer, // Sprawdza odpowiedź
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
