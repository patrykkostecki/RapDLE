import 'dart:convert';
import 'dart:html';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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
  List<String> _selectedLines = [];
  String _currentSongName = "";
  int _displayedLinesCount = 1;
  String _message = "";
  int _attempts = 0;
  AnimationController? _animationController;
  final _random = Random();
  List<String> _textNames = [];

  @override
  void initState() {
    super.initState();
    fetchTextNames();
    fetchRandomLyrics();
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

  // Funkcja do generowania sugestii dla autouzupełnienia
  Future<List<String>> getSuggestions(String query) async {
    // Filtrowanie lokalne na podstawie pobranej listy _textNames
    List<String> matches = [];

    matches.addAll(_textNames.where(
      (text) => text.toLowerCase().contains(query.toLowerCase()),
    ));

    return matches;
  }

  Future<void> fetchTextNames() async {
    final listResult = await FirebaseStorage.instance.ref('text').listAll();
    final textNames =
        listResult.items.map((item) => item.name.split('.').first).toList();

    setState(() {
      _textNames = textNames;
    });
  }

  Future<void> fetchRandomLyrics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String storedDate = prefs.getString('date') ?? '';
    String storedLyrics = prefs.getString('lyrics') ?? '';
    String storedSongName = prefs.getString('songName') ?? '';

    if (storedDate == today &&
        storedLyrics.isNotEmpty &&
        storedSongName.isNotEmpty) {
      // Jeśli data się zgadza, używamy zapisanych danych
      setState(() {
        _selectedLines = storedLyrics.split('\n');
        _currentLyrics = _selectedLines
            .take(1)
            .join('\n'); // Tylko pierwsza linia na początku
        _currentSongName = storedSongName;
        _message = "";
        _displayedLinesCount = 1; // Resetujemy licznik wyświetlanych linii
      });
      return;
    }

    try {
      final ref = FirebaseStorage.instance.ref('text/');
      final result = await ref.listAll();

      if (result.items.isNotEmpty) {
        int randomIndex = _random.nextInt(result.items.length);
        final selectedFileRef = result.items[randomIndex];
        final songName = selectedFileRef.name.split('.').first;
        final url = await selectedFileRef.getDownloadURL();
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final lyricsUtf8 = utf8.decode(response.bodyBytes);
          final lines =
              lyricsUtf8.split('\n').where((line) => line.isNotEmpty).toList();

          int startIndex = _random.nextInt(lines.length - 4);
          _selectedLines = lines.sublist(startIndex, startIndex + 4);
          String selectedLyrics = _selectedLines
              .take(1)
              .join('\n'); // Tylko pierwsza linia na początku

          setState(() {
            _currentLyrics = selectedLyrics;
            _currentSongName = songName;
            _message = "";
            _displayedLinesCount =
                1; // Resetowanie licznika wyświetlanych linii
          });

          // Zapis do SharedPreferences
          await prefs.setString('date', today);
          await prefs.setString('lyrics',
              _selectedLines.join('\n')); // Zapisujemy wszystkie linie
          await prefs.setString('songName', songName);

          _animationController!.duration = Duration(seconds: 1);
          _animationController!
              .forward()
              .whenComplete(() => _animationController!.reset());
        } else {
          print('Failed to load lyrics');
          setState(() {
            _message = "Failed to load lyrics";
          });
        }
      } else {
        print('No lyrics files found');
        setState(() {
          _message = "No lyrics files found";
        });
      }
    } catch (e) {
      print('Error fetching lyrics: $e');
      setState(() {
        _message = 'Error fetching lyrics: $e';
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
        if (_attempts >= 4) {
          widget.onLose(2); // Too many attempts, fail
        } else {
          _message = "Błąd! Spróbuj jeszcze raz!";
          if (_displayedLinesCount < _selectedLines.length) {
            _displayedLinesCount++;
            _currentLyrics =
                _selectedLines.take(_displayedLinesCount).join('\n');
          }
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
          height: 420,
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
                  Text(
                    'Odgadnij tekst piosenkii',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        fontFamily: 'CrayonPaperDemoRegular'),
                  ),
                  Text('Masz na to tylko 4 próby!'),
                  SizedBox(height: 6),
                  Container(
                    width: 450,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        _currentLyrics,
                        textAlign: TextAlign
                            .center, // Centrowanie tekstu wewnątrz kontenera
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Ilość prób: $_attempts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Pogrubienie tekstu
                    ),
                  ),
                  Text(_message),

                  // Display the selected lyrics
                  SizedBox(height: 5),
                  SizedBox(
                    width: 550,
                    child: TypeAheadFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: "Wpisz nazwę piosenki...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      suggestionsCallback: (pattern) async {
                        return await getSuggestions(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        _textController.text = suggestion;
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 30,
                      ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
