import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:rapdle/widgets/bottom_bar.dart';
import 'package:rapdle/widgets/featured_heading.dart';
import 'package:rapdle/widgets/featured_tiles.dart';
import 'package:rapdle/widgets/floating_quick_acces_bar.dart';
import 'package:rapdle/widgets/top_bar_contest';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0;
  double _opacity = 0;
  String path = '/Users/a1234/Desktop/Aplikacje/RapDLE/rapdle/assets';

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

    return Scaffold(
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
                      path + '/background.png',
                      // fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  children: [
                    FloatingQuickAccessBar(screenSize: screenSize),
                    SizedBox(
                      height: 50,
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
    );
  }
}
