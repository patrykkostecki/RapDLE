import 'package:flutter/material.dart';
import 'package:rapdle/screen/win_screen.dart';
import 'package:rapdle/widgets/bottom_bar.dart';
import 'package:rapdle/widgets/featured_heading.dart';
import 'package:rapdle/widgets/featured_tiles.dart';
import 'package:rapdle/widgets/floating_quick_acces_bar.dart';
import 'package:rapdle/widgets/guess_cover.dart';
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
  String currentSongName = '';

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

  void resetGameState() {
    setState(() {
      hasLost = 0;
      screenState = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    _opacity = _scrollPosition < screenSize.height * 0.40
        ? _scrollPosition / (screenSize.height * 0.40)
        : 1;

    return WillPopScope(
      onWillPop: () async {
        setState(() {
          screenState = 0;
        });
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
            preferredSize: Size(screenSize.width, 70),
            child: TopBarContents(_opacity, onLogoClicked: resetGameState)),
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
                              screenState = index + 1;
                            });
                          },
                        ),
                      if (screenState == 1 ||
                          screenState == 2 ||
                          screenState == 3)
                        SizedBox(
                          height: 50,
                        ),
                      if (screenState == 1 && hasLost == 0) // GuessTheSong
                        GuessTheSong(
                          screenSize: screenSize,
                          onLose: (String songName, bool isWin) {
                            setState(() {
                              if (isWin) {
                                hasLost = 1;
                              } else {
                                hasLost = 2;
                              }
                              currentSongName = songName;
                            });
                          },
                        ),
                      if (screenState == 2 && hasLost == 0) // GuessTheLyrics
                        GuessTheLyrics(
                          screenSize: screenSize,
                          onLose: (String songName, bool isWin) {
                            setState(() {
                              if (isWin) {
                                hasLost = 1;
                              } else {
                                hasLost = 2;
                              }
                              currentSongName = songName;
                            });
                          },
                        ),
                      if (screenState == 3 && hasLost == 0) // GuessTheCover
                        GuessTheCover(
                          screenSize: screenSize,
                          onLose: (String songName, bool isWin) {
                            setState(() {
                              if (isWin) {
                                hasLost = 1;
                              } else {
                                hasLost = 2;
                              }
                              currentSongName = songName;
                            });
                          },
                        ),
                      if (hasLost == 2) // LoseScreen
                        LoseScreen(
                          songName: currentSongName,
                          imagePath: 'URL obrazu',
                          onRetry: () {
                            setState(() {
                              hasLost = 0;
                              screenState = 0;
                            });
                          },
                        ),
                      if (hasLost == 1) // WinScreen
                        WinScreen(
                          songName: currentSongName,
                          imagePath: 'URL obrazu',
                          onRetry: () {
                            setState(() {
                              hasLost = 0;
                              screenState = 0;
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
