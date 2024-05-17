import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:html' as html; // Alias dla dart:html

class GuessTheCover extends StatefulWidget {
  const GuessTheCover(
      {Key? key, required this.screenSize, required this.onLose})
      : super(key: key);

  final Size screenSize;
  final Function(int) onLose;

  @override
  _GuessTheCoverState createState() => _GuessTheCoverState();
}

class _GuessTheCoverState extends State<GuessTheCover> {
  final TextEditingController _textController = TextEditingController();
  String _currentCoverName = "";
  String _currentCoverUrl = "";
  String _message = "";
  int _attempts = 0;
  double _clipFactorX = 0.0; // Initial clip factor X
  double _clipFactorY = 0.0; // Initial clip factor Y
  double blurX = 16;
  double blurY = 16;
  List<String> _coverNames = [];

  @override
  void initState() {
    super.initState();
    fetchCoverNames();
    selectRandomCoverDaily();
    Timer.periodic(Duration(minutes: 1), (Timer t) {
      final now = DateTime.now();
      if (now.hour == 0 && now.minute == 0) {
        print('Changing cover at midnight');
        selectRandomCoverDaily();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Funkcja do generowania sugestii dla autouzupełnienia
  Future<List<String>> getSuggestions(String query) async {
    // Filtrowanie lokalne na podstawie pobranej listy _coverNames
    List<String> matches = [];

    matches.addAll(_coverNames.where(
      (cover) => cover.toLowerCase().contains(query.toLowerCase()),
    ));

    return matches;
  }

  Future<void> selectRandomCoverDaily() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPickedTimestamp =
        html.window.localStorage['lastPickedTimestampCover'];
    final lastPickedDate = lastPickedTimestamp != null
        ? DateTime.parse(lastPickedTimestamp)
        : null;
    final nextSelectionDate = lastPickedDate != null
        ? DateTime(
                lastPickedDate.year, lastPickedDate.month, lastPickedDate.day)
            .add(Duration(days: 1))
        : null;
    final selectionTime = DateTime(today.year, today.month, today.day, 0, 0);

    if (lastPickedDate == null ||
        (now.isAfter(selectionTime) &&
            (nextSelectionDate == null || now.isAfter(nextSelectionDate)))) {
      final listResult = await firebase_storage.FirebaseStorage.instance
          .ref('covers')
          .listAll();
      final covers = listResult.items.map((item) => item.name).toList();
      final randomCoverName = covers[Random().nextInt(covers.length)];

      final url = await firebase_storage.FirebaseStorage.instance
          .ref('covers/$randomCoverName')
          .getDownloadURL();

      html.window.localStorage['lastPickedTimestampCover'] =
          now.toIso8601String();
      html.window.localStorage['currentCoverName'] =
          randomCoverName.split('.').first;
      html.window.localStorage['currentCoverUrl'] = url;

      setState(() {
        _currentCoverName = html.window.localStorage['currentCoverName']!;
        _currentCoverUrl = html.window.localStorage['currentCoverUrl']!;
      });
    } else {
      setState(() {
        _currentCoverName = html.window.localStorage['currentCoverName']!;
        _currentCoverUrl = html.window.localStorage['currentCoverUrl']!;
      });
    }
  }

  void _checkAnswer() {
    if (_textController.text.trim().toLowerCase() ==
        _currentCoverName.toLowerCase()) {
      widget.onLose(1); // Call win screen
    } else {
      setState(() {
        _attempts++;
        if (_attempts >= 8) {
          widget.onLose(2); // Call lose screen after too many attempts
        } else {
          _message = "Błąd! Spróbuj jeszcze raz!";
          if (blurX > 0 || blurY > 0) {
            blurX -= 2;
            blurY -= 2;
          }
        }
      });
    }
  }

  void _zoomIn() {
    setState(() {
      _clipFactorX = Random().nextDouble(); // Change clip factor X randomly
      _clipFactorY = Random().nextDouble(); // Change clip factor Y randomly
    });
  }

  Future<void> fetchCoverNames() async {
    final listResult = await FirebaseStorage.instance.ref('covers').listAll();
    final coverNames =
        listResult.items.map((item) => item.name.split('.').first).toList();

    setState(() {
      _coverNames = coverNames;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: widget.screenSize.height * 0.20,
          left: widget.screenSize.width / 5,
          right: widget.screenSize.width / 5,
        ),
        child: Container(
          width: 800,
          height: 460,
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
                  Text(
                    'Odgadnij okładke albumu',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        fontFamily: 'CrayonPaperDemoRegular'),
                  ),
                  Text('W tym trybie masz az 8 prób!'),
                  if (_currentCoverUrl.isNotEmpty)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          _currentCoverUrl,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        ClipRect(
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: blurX, sigmaY: blurY),
                            child: Container(
                              width: 200,
                              height: 200,
                              color: Colors.black.withOpacity(0.5),
                              alignment: Alignment(_clipFactorX, _clipFactorY),
                            ),
                          ),
                        ),
                      ],
                    ),
                  Text(
                    'Ilość prób: $_attempts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(_message),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 550,
                    child: TypeAheadFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: "Wpisz nazwę okładki...",
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
                      SizedBox(width: 30),
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
