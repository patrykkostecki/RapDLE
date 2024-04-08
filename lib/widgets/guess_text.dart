import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class GuessTheLyrics extends StatefulWidget {
  const GuessTheLyrics(
      {Key? key, required this.screenSize, required this.onLose})
      : super(key: key);

  final Size screenSize;
  final Function(int) onLose;

  @override
  _GuessTheLyricsState createState() => _GuessTheLyricsState();
}

class _GuessTheLyricsState extends State<GuessTheLyrics>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  String _currentLyrics = "";
  List<String> _selectedLines = []; // Przechowuje wybrane linijki tekstu
  String _currentSongName = "";
  String _message = "";
  int _attempts = 0;
  AnimationController? _animationController;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    Firebase.initializeApp();
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> fetchLyrics(String filePath, String songName) async {
    try {
      final ref = FirebaseStorage.instance.ref(filePath);
      final url = await ref.getDownloadURL();
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Dekodowanie treści piosenki jako UTF-8.
        final lyricsUtf8 = utf8.decode(response.bodyBytes);
        final lines =
            lyricsUtf8.split('\n').where((line) => line.isNotEmpty).toList();

        // Losowanie indeksu początkowego dla fragmentu 4 linijek tekstu
        int startIndex = _random
            .nextInt(lines.length - 4); // -4 aby uniknąć przekroczenia zakresu
        _selectedLines = lines.sublist(startIndex, startIndex + 4);

        setState(() {
          _currentLyrics = _selectedLines
              .join('\n'); // Łączenie wybranych linijek w jeden ciąg tekstowy
          _currentSongName = songName;
          _message = "";
        });
        // Uruchomienie animacji
        _animationController!.duration = Duration(seconds: 1);
        _animationController!
            .forward()
            .whenComplete(() => _animationController!.reset());
      } else {
        print('Failed to load lyrics');
        setState(() {
          _message =
              "Failed to load lyrics"; // Dodaj tę linię, aby wyświetlić błąd na UI
        });
      }
    } catch (e) {
      print('Error fetching lyrics: $e');
      setState(() {
        _message =
            'Error fetching lyrics: $e'; // Ustawienie wiadomości błędu do wyświetlenia na UI
      });
    }
  }

  void _checkAnswer() {
    if (_textController.text.trim().toLowerCase() ==
        _currentSongName.toLowerCase()) {
      setState(() {
        widget.onLose(1); // Success
      });
    } else {
      setState(() {
        _attempts++;
        if (_attempts >= 5) {
          widget.onLose(2); // Too many attempts, fail
        } else {
          _message = "Try again!";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: widget.screenSize.height * 0.60,
          left: 20,
          right: 20,
        ),
        child: Container(
          width: 800,
          height: 380,
          // Added container for custom decoration
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
            color: Colors.white, // Specifying card color
            elevation: 0, // Removed elevation to use custom shadow
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_currentLyrics), // Display the selected lyrics
                  SizedBox(height: 10),
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
                  Text(_message),
                  Text('Ilosc Prób: $_attempts'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () =>
                            fetchLyrics('text/Kizo-Hero.txt', 'Hero'),
                      ),
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: _checkAnswer,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
