import 'package:flutter/material.dart';
import 'package:rapdle/widgets/responsive.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

class GuessTheSong extends StatefulWidget {
  const GuessTheSong({
    Key? key,
    required this.screenSize,
  }) : super(key: key);

  final Size screenSize;

  @override
  _GuessTheSongState createState() => _GuessTheSongState();
}

class _GuessTheSongState extends State<GuessTheSong> {
  final TextEditingController _textController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _textController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playSong(String filePath) async {
    try {
      final url = await FirebaseStorage.instance.ref(filePath).getDownloadURL();
      await audioPlayer.play(UrlSource(url));
    } catch (e) {
      print('Wystąpił błąd podczas odtwarzania piosenki: $e');
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
                    hintText: "Wpisz nazwę piosenki..",
                    border: OutlineInputBorder(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      onPressed: () {
                        // Tutaj logika przewijania do poprzedniego utworu
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        playSong('test.mp3');
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: () {
                        audioPlayer.pause();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed: () {
                        // Tutaj logika przewijania do następnego utworu
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
