import 'dart:async';
import 'dart:html';
import 'dart:math';
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
import 'package:flutter_web_plugins/flutter_web_plugins.dart'; // Dodane do używania localStorage

class GuessTheSong extends StatefulWidget {
  const GuessTheSong({Key? key, required this.screenSize, required this.onLose})
      : super(key: key);

  final Size screenSize;
  final Function(int) onLose;

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
        AnimationController(vsync: this, duration: Duration(seconds: 10));
    Timer.periodic(Duration(minutes: 1), (Timer t) {
      final now = DateTime.now();
      if (now.hour == 5 && now.minute == 42) {
        print('test2');
        selectRandomSongDaily();
      }
    });
    selectRandomSongDaily(); // Wywołanie początkowe, aby ustawić piosenkę na start.
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
      _animationController!.duration = Duration(seconds: 10);
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
      // Należy zmienić logikę wywołania naLose na odpowiednią, np. wyświetlenie ekranu zwycięstwa
      widget.onLose(1); // Przykład wywołania ekranu przegranej
    } else {
      setState(() {
        _attempts++;
        if (_attempts >= 5) {
          widget.onLose(
              2); // Przykład wywołania ekranu przegranej po przekroczeniu prób
        } else {
          _message = "Błąd! Spróbuj jeszcze raz!";
          selectRandomSongDaily();
          print("test");
        }
      });
    }
  }

  Future<void> selectRandomSongDaily() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPickedTimestamp = window.localStorage['lastPickedTimestamp'];
    final lastPickedDate = lastPickedTimestamp != null
        ? DateTime.parse(lastPickedTimestamp)
        : null;
    final nextSelectionDate = lastPickedDate != null
        ? DateTime(
                lastPickedDate.year, lastPickedDate.month, lastPickedDate.day)
            .add(Duration(days: 1))
        : null;
    final selectionTime = DateTime(
        today.year, today.month, today.day, 5, 35); // Ustawiona godzina na 5:15

    if (lastPickedDate == null ||
        (now.isAfter(selectionTime) &&
            (nextSelectionDate == null || now.isAfter(nextSelectionDate)))) {
      final listResult = await FirebaseStorage.instance.ref('songs').listAll();
      final songs = listResult.items.map((item) => item.name).toList();
      final randomSongName = songs[Random().nextInt(songs.length)];

      window.localStorage['lastPickedTimestamp'] = now.toIso8601String();
      window.localStorage['currentSongName'] = randomSongName.split('.').first;

      print("Losowanie piosenki o godzinie: ${DateTime.now()}");

      setState(() {
        _currentSongName = window.localStorage['currentSongName']!;
      });
    } else {
      setState(() {
        _currentSongName = window.localStorage['currentSongName']!;
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
        child: Container(
          width: 800,
          height: 400,
          decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(255, 90, 90, 90),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFAC8115).withOpacity(0.4),
                spreadRadius: 2,
                blurRadius: 100,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Card(
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'PlayAnimation.json',
                    width: 200,
                    height: 200,
                    controller: _animationController,
                  ),
                  Text(
                    'Ilość prób: $_attempts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Pogrubienie tekstu
                    ),
                  ),
                  Text(_message),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 550,
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "Wpisz nazwę piosenki...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final songName =
                              window.localStorage['currentSongName'];
                          if (songName != null) {
                            final filePath = 'songs/$songName.mp3';
                            playSong(filePath, songName);
                          }
                          // Logika przycisku odtwarzania
                        },
                        child: Text('Odtwórz'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color.fromARGB(255, 0, 78, 141),
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                      SizedBox(width: 30), // Odstęp między przyciskami
                      ElevatedButton(
                        onPressed: _checkAnswer,
                        child: Text('Zatwierdź'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromARGB(255, 0, 99, 0),
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
