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
        AnimationController(vsync: this, duration: Duration(seconds: 1));
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
      _animationController!.duration = Duration(seconds: 1);
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
          _message = "Spróbuj jeszcze raz!";
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
                      onPressed: () {
                        // Pobierz nazwę piosenki z localStorage
                        final songName = window.localStorage['currentSongName'];
                        if (songName != null) {
                          // Użyj nazwy piosenki do skonstruowania ścieżki
                          final filePath =
                              'songs/$songName.mp3'; // Dostosuj, jeśli potrzebujesz innej struktury ścieżki
                          playSong(filePath, songName);
                        }
                      },
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
