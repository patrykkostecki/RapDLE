import 'package:flutter/material.dart';
import 'package:rapdle/screen/win_screen.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:rapdle/widgets/bottom_bar.dart';
import 'package:rapdle/widgets/featured_heading.dart';
import 'package:rapdle/widgets/featured_tiles.dart';
import 'package:rapdle/widgets/floating_quick_acces_bar.dart';
import 'package:rapdle/widgets/guess_song.dart';
import 'package:rapdle/screen/lose_screen.dart';
import 'package:rapdle/widgets/guess_text.dart';
import 'package:rapdle/widgets/top_bar_contest';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0;
  double _opacity = 0;
  int screenState = 0;
  String path = '/Users/a1234/Desktop/Aplikacje/RapDLE/rapdle/assets';
  int hasLost = 0;

  _scrollListener() {
    setState(() {
      _scrollPosition = _scrollController.position.pixels;
    });
  }

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    _opacity = _scrollPosition < screenSize.height * 0.40
        ? _scrollPosition / (screenSize.height * 0.40)
        : 1;

    return WillPopScope(
      onWillPop: () async {
        // Resetuj screenState do 0
        setState(() {
          screenState = 0;
        });
        // Zwracając false, zapobiegasz wykonaniu akcji powrotu (pop)
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
            preferredSize: Size(screenSize.width, 70),
            child: TopBarContents(_opacity)),
        backgroundColor: Color(0xFFC9C5CA),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    child: SizedBox(
                      height: screenSize.height * 0.75,
                      width: screenSize.width,
                      child: Image.asset(
                        'assets/background.png',
                        // fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      if (screenState == 0)
                        FloatingQuickAccessBar(
                          screenSize: screenSize,
                          onItemTap: (index) {
                            setState(() {
                              screenState = index +
                                  1; // Zaktualizuj stan na podstawie wybranego elementu
                            });
                          },
                        ),
                      if (screenState == 1 ||
                          screenState == 2 ||
                          screenState == 3)
                        SizedBox(
                          height: 50,
                        ),
                      if (screenState == 1)
                        if (hasLost == 0) // Dla "Dźwięk"
                          GuessTheSong(
                            screenSize: screenSize,
                            onLose: (int value) {
                              setState(() {
                                hasLost = value;
                              });
                            },
                          ),
                      if (hasLost == 2)
                        LoseScreen(
                          songName: 'Nazwa utworu',
                          imagePath: 'URL obrazu',
                          onRetry: () {
                            setState(() {
                              hasLost = 0;
                              screenState =
                                  0; // Wróć do początkowego stanu/ekranu
                            });
                          },
                        ),
                      if (hasLost == 1)
                        WinScreen(
                            songName: 'Nazwa utworu',
                            imagePath: 'URL obrazu',
                            onRetry: () {
                              setState(() {
                                hasLost = 0;
                                screenState =
                                    0; // Wróć do początkowego stanu/ekranu
                              });
                            }),
                      //   // Dla "Tekst"
                      if (screenState == 2)
                        GuessTheLyrics(
                          screenSize: screenSize,
                          onLose: (int value) {
                            setState(() {
                              hasLost = value;
                            });
                          },
                        ),

                      if (screenState >= 0)
                        SizedBox(
                          height: 150,
                        ),
                      FeaturedHeading(screenSize: screenSize),
                      FeaturedTiles(screenSize: screenSize),
                      SizedBox(
                        height: 50,
                      ),
                      BottomBar(),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
