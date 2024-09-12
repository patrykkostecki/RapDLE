import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:rapdle/widgets/responsive.dart';

class GuessTheLyrics extends StatefulWidget {
  const GuessTheLyrics(
      {Key? key, required this.screenSize, required this.onLose})
      : super(key: key);

  final Size screenSize;
  final Function(String, bool) onLose;

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

  Future<List<String>> getSuggestions(String query) async {
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
      setState(() {
        _selectedLines = storedLyrics.split('\n');
        _currentLyrics = _selectedLines.take(1).join('\n');
        _currentSongName = storedSongName;
        _message = "";
        _displayedLinesCount = 1;
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
          String selectedLyrics = _selectedLines.take(1).join('\n');

          setState(() {
            _currentLyrics = selectedLyrics;
            _currentSongName = songName;
            _message = "";
            _displayedLinesCount = 1;
          });

          await prefs.setString('date', today);
          await prefs.setString('lyrics', _selectedLines.join('\n'));
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
      widget.onLose(_currentSongName, true); // Przekazujemy true dla wygranej
    } else {
      setState(() {
        _attempts++;
        if (_attempts >= 4) {
          widget.onLose(
              _currentSongName, false); // Przekazujemy false dla przegranej
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
    return ResponsiveWidget(
      largeScreen: Center(
        heightFactor: 1,
        child: Padding(
          padding: EdgeInsets.only(
            top: 100,
            left: 50,
            right: 50,
          ),
          child: buildMainContainer(800, 650, 45),
        ),
      ),
      smallScreen: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 50,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child:
              buildMainContainer(double.infinity, 600, 30), // Mniejsze ekrany
        ),
      ),
    );
  }

  Widget buildMainContainer(double width, double height, double fontSize) {
    return Container(
      width: width,
      height: height,
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
                  'Odgadnij tekst piosenki',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize, // Dynamiczny rozmiar tekstu
                    fontFamily: 'CrayonPaperDemoRegular',
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 45.0),
                ),
                SizedBox(height: 10),
                buildLyricsDisplay(),
                SizedBox(height: 10),
                Text(
                  'Ilość prób: $_attempts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(_message),
                SizedBox(height: 5),
                buildInputField(),
                SizedBox(height: 20),
                buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLyricsDisplay() {
    return Container(
      width: 450,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.all(10),
      child: Center(
        child: Text(
          _currentLyrics,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildInputField() {
    return Container(
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
    );
  }

  Widget buildSubmitButton() {
    return ElevatedButton(
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
    );
  }
}
