import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_typeahead/flutter_typeahead.dart';

class GuessRandomSong extends StatefulWidget {
  const GuessRandomSong({Key? key, required this.screenSize}) : super(key: key);

  final Size screenSize;

  @override
  _GuessRandomSongState createState() => _GuessRandomSongState();
}

class _GuessRandomSongState extends State<GuessRandomSong>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();
  String _currentSongName = "";
  String _message = "";
  int _attempts = 0;
  AnimationController? _animationController;
  List<String> _songNames = [];
  String? _lastSongName;
  int _lastSongAttempts = 0;

  @override
  void initState() {
    super.initState();
    fetchSongNames();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    selectRandomSong();
  }

  @override
  void dispose() {
    _textController.dispose();
    audioPlayer.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> fetchSongNames() async {
    final listResult = await FirebaseStorage.instance.ref('songs').listAll();
    final songNames =
        listResult.items.map((item) => item.name.split('.').first).toList();
    setState(() {
      _songNames = songNames;
    });
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
      for (int i = 0; i < _attempts + 1; i++) {
        await _animationController!.forward().whenComplete(() async {
          _animationController!.reset();
        });
      }
    } catch (e) {
      print('Wystąpił błąd podczas odtwarzania piosenki: $e');
    }
  }

  void _checkAnswer() {
    if (_textController.text.trim().toLowerCase() ==
        _currentSongName.toLowerCase()) {
      setState(() {
        _lastSongName = _currentSongName;
        _lastSongAttempts = _attempts + 1;
        _attempts = 0;
        selectRandomSong();
      });
    } else {
      setState(() {
        _attempts++;
        if (_attempts >= 5) {
          _lastSongName = _currentSongName;
          _lastSongAttempts = _attempts;
          _attempts = 0;
          selectRandomSong();
        } else {
          _message = "Błąd! Spróbuj jeszcze raz!";
        }
      });
    }
  }

  Future<void> selectRandomSong() async {
    final listResult = await FirebaseStorage.instance.ref('songs').listAll();
    final songs = listResult.items.map((item) => item.name).toList();
    final randomSongName =
        songs[Random().nextInt(songs.length)].split('.').first;

    setState(() {
      _currentSongName = randomSongName;
    });
  }

  Future<List<String>> getSuggestions(String query) async {
    List<String> matches = [];

    matches.addAll(_songNames.where(
      (song) => song.toLowerCase().contains(query.toLowerCase()),
    ));

    return matches;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Center(
      heightFactor: 1,
      child: Padding(
        padding: EdgeInsets.only(
          top: 100,
          left: 50,
          right: 50,
        ),
        child: Container(
          width: 800,
          height: 780,
          decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(251, 39, 39, 39),
              width: 4,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFAC8115).withOpacity(0.4),
                spreadRadius: 30,
                blurRadius: 100,
                offset: Offset(0, 2),
              ),
            ],
            gradient: RadialGradient(
              colors: [
                Color.fromARGB(236, 255, 255, 255),
                Color.fromRGBO(161, 161, 161, 0.922),
              ],
              center: Alignment.center,
              radius: 2.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Card(
              margin: EdgeInsets.zero,
              color: Colors.transparent,
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Guess sonG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 45,
                        fontFamily: 'CrayonPaperDemoRegular',
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 45.0),
                      child: Text(
                        'Kliknij przycisk "Odtwórz", aby odtworzyć losowy fragment piosenki. '
                        'Kiedy rozpoznasz piosenkę, wpisz jej tytuł i kliknij "Zatwierdź".\n\n'
                        'Masz łącznie 5 prób!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Lottie.network(
                      'https://raw.githubusercontent.com/patrykkostecki/rapDLE/main/assets/PlayAnimationOLD.json',
                      width: 275,
                      height: 275,
                      controller: _animationController,
                    ),
                    Text(
                      'Ilość prób: $_attempts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(_message),
                    SizedBox(height: 5),
                    Container(
                      width: 550,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 60,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TypeAheadFormField(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: "Wpisz nazwę piosenki...",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 0, 7, 73),
                                width: 2.0,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        suggestionsCallback: (pattern) async {
                          return await getSuggestions(pattern);
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(
                              suggestion,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          _textController.text = suggestion;
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_currentSongName.isNotEmpty) {
                              final filePath = 'songs/$_currentSongName.mp3';
                              playSong(filePath, _currentSongName);
                            }
                          },
                          child: Container(
                            height: 50.0,
                            width: 150.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 0, 78, 141),
                                  Color.fromARGB(255, 0, 73, 122),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(80.0),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 17, 17, 17)
                                      .withOpacity(0.8),
                                  blurRadius: 30,
                                  offset: Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: Color.fromARGB(172, 32, 32, 32),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              'Odtwórz',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 230, 230, 230),
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0),
                            ),
                          ),
                        ),
                        SizedBox(width: 50),
                        ElevatedButton(
                          onPressed: _checkAnswer,
                          child: Container(
                            height: 50.0,
                            width: 150.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(211, 0, 99, 0),
                                  Color.fromARGB(210, 0, 78, 0),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 30,
                                  offset: Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: Color.fromARGB(172, 32, 32, 32),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              'Zatwierdź',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 230, 230, 230),
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
