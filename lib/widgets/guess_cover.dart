import 'dart:math';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rapdle/widgets/responsive.dart'; // Importing the responsive widget

class GuessTheCover extends StatefulWidget {
  const GuessTheCover(
      {Key? key, required this.screenSize, required this.onLose})
      : super(key: key);

  final Size screenSize;
  final Function(String, bool) onLose;

  @override
  _GuessTheCoverState createState() => _GuessTheCoverState();
}

class _GuessTheCoverState extends State<GuessTheCover> {
  final TextEditingController _textController = TextEditingController();
  String _currentCoverName = "";
  String _currentCoverUrl = "";
  String _message = "";
  int _attempts = 0;
  double _clipFactorX = 0.0;
  double _clipFactorY = 0.0;
  double blurX = 16;
  double blurY = 16;
  List<String> _coverNames = [];

  @override
  void initState() {
    super.initState();
    fetchCoverNames();
    selectRandomCoverDaily();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<List<String>> getSuggestions(String query) async {
    List<String> matches = [];

    matches.addAll(_coverNames.where(
      (cover) => cover.toLowerCase().contains(query.toLowerCase()),
    ));

    return matches;
  }

  Future<void> selectRandomCoverDaily() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final prefs = await SharedPreferences.getInstance();
    final lastPickedTimestamp = prefs.getString('lastCoverPickedTimestamp');
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
      final listResult = await FirebaseStorage.instance.ref('covers').listAll();
      final covers = listResult.items.map((item) => item.name).toList();
      final randomCoverName = covers[Random().nextInt(covers.length)];

      final url = await FirebaseStorage.instance
          .ref('covers/$randomCoverName')
          .getDownloadURL();

      await prefs.setString('lastCoverPickedTimestamp', now.toIso8601String());
      await prefs.setString(
          'currentCoverName', randomCoverName.split('.').first);
      await prefs.setString('currentCoverUrl', url);

      print("Losowanie okładki o godzinie: ${DateTime.now()}");

      setState(() {
        _currentCoverName = prefs.getString('currentCoverName')!;
        _currentCoverUrl = prefs.getString('currentCoverUrl')!;
      });
    } else {
      setState(() {
        _currentCoverName = prefs.getString('currentCoverName')!;
        _currentCoverUrl = prefs.getString('currentCoverUrl')!;
      });
    }
  }

  void _checkAnswer() {
    if (_textController.text.trim().toLowerCase() ==
        _currentCoverName.toLowerCase()) {
      widget.onLose(_currentCoverName, true);
    } else {
      setState(() {
        _attempts++;
        if (_attempts >= 8) {
          widget.onLose(_currentCoverName, false);
        } else {
          _message = "Błąd! Spróbuj jeszcze raz!";
          if (blurX > 0 || blurY > 0) {
            blurX -= 2;
            blurY -= 2;
          }

          selectRandomCoverDaily();
        }
      });
    }
  }

  void _zoomIn() {
    setState(() {
      _clipFactorX = Random().nextDouble();
      _clipFactorY = Random().nextDouble();
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
    return ResponsiveWidget(
      largeScreen: _buildLargeScreenUI(widget.screenSize),
      smallScreen: _buildSmallScreenUI(widget.screenSize),
    );
  }

  // Large screen UI
  Widget _buildLargeScreenUI(Size screenSize) {
    return Center(
      heightFactor: 1,
      child: Padding(
        padding: EdgeInsets.only(
          top: screenSize.height * 0.20,
          left: screenSize.width / 5,
          right: screenSize.width / 5,
        ),
        child: Container(
          width: 800,
          height: 700,
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
                child: _buildCommonUI(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Small screen UI (Mobile)
  Widget _buildSmallScreenUI(Size screenSize) {
    return Center(
      heightFactor: 1,
      child: Padding(
        padding: EdgeInsets.only(
          top: 50,
          left: 20,
          right: 20,
        ),
        child: Container(
          width: screenSize.width * 0.9,
          height: screenSize.height * 0.9,
          decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(251, 39, 39, 39),
              width: 2, // Thinner border for smaller screens
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFAC8115).withOpacity(0.4),
                spreadRadius: 15,
                blurRadius: 50,
                offset: Offset(0, 1),
              ),
            ],
            gradient: RadialGradient(
              colors: [
                Color.fromARGB(236, 255, 255, 255),
                Color.fromRGBO(161, 161, 161, 0.922),
              ],
              center: Alignment.center,
              radius: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Card(
              margin: EdgeInsets.zero,
              color: Colors.transparent,
              elevation: 15,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(5),
                child: _buildCommonUI(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Common UI elements
  Widget _buildCommonUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20),
        Text(
          'Guess coveR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25, // Smaller font size for mobile
            fontFamily: 'CrayonPaperDemoRegular',
          ),
        ),
        SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Po wejściu do ramki zobaczysz rozmazaną okładkę albumu. '
            'Kiedy rozpoznasz okładkę, wpisz jej tytuł w pasku wyboru i kliknij "Zatwierdź". '
            'Co każdą próbę okładka stanie się bardziej wyraźna aż do 8 razy!\n\nMasz łącznie 8 prób!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13, // Smaller font size for mobile
            ),
          ),
        ),
        SizedBox(height: 15),
        if (_currentCoverUrl.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromARGB(212, 15, 15, 15),
                width: 1.5, // Thinner border for smaller screens
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  _currentCoverUrl,
                  width: 150, // Smaller image for mobile
                  height: 150,
                  fit: BoxFit.cover,
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: blurX, sigmaY: blurY),
                    child: Container(
                      width: 150,
                      height: 150,
                      color: Colors.black.withOpacity(0.5),
                      alignment: Alignment(_clipFactorX, _clipFactorY),
                    ),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: 10),
        Text(
          'Ilość prób: $_attempts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14, // Adjust size for mobile
          ),
        ),
        SizedBox(height: 5),
        Text(_message),
        SizedBox(height: 5),
        Container(
          width: 300, // Reduced width for mobile
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Wpisz nazwę albumu...",
                hintStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13, // Adjusted for mobile
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 1.5, // Adjusted for mobile
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 0, 7, 73),
                    width: 1.5,
                  ),
                ),
              ),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13, // Adjusted for mobile
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
                    fontSize: 13, // Adjusted for mobile
                  ),
                ),
              );
            },
            onSuggestionSelected: (suggestion) {
              _textController.text = suggestion;
            },
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _checkAnswer,
          child: Container(
            height: 40.0,
            width: 120.0,
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
                fontSize: 16,
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
    );
  }
}
