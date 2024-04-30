import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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
  List<String> _selectedLines = [];
  String _currentSongName = "";
  String _message = "";
  int _attempts = 0;
  AnimationController? _animationController;
  final _random = Random();
  List<String> _textNames = [];

  @override
  void initState() {
    super.initState();
    fetchTextNames();
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
        for (int i = 1; i <= _attempts + 1; i++) {
          int startIndex = _random.nextInt(
              lines.length - 4); // -4 aby uniknąć przekroczenia zakresu
          _selectedLines = lines.sublist(startIndex, startIndex + i);
        }

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
        if (_attempts >= 4) {
          widget.onLose(2); // Too many attempts, fail
        } else {
          _message = "Błąd! Spróbuj jeszcze raz!";
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
                  SizedBox(height: 10),
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
                      ElevatedButton(
                        onPressed: () =>
                            fetchLyrics('text/Kizo-Hero.txt', 'Hero'),
                        child: Text('Pokaż'),
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
