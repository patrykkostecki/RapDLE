import 'package:flutter/material.dart';
import 'package:rapdle/widgets/responsive.dart';
import 'package:lottie/lottie.dart';

class LoseScreen extends StatelessWidget {
  final String songName;
  final String imagePath;
  final VoidCallback onRetry;

  const LoseScreen({
    Key? key,
    required this.songName,
    required this.imagePath,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: buildMainContent(800, 45, 25, 35), // Dla dużych ekranów
      smallScreen: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 50,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: buildMainContent(
              double.infinity, 30, 20, 28), // Dla małych ekranów
        ),
      ),
    );
  }

  Widget buildMainContent(double width, double titleFontSize,
      double textFontSize, double songFontSize) {
    return Center(
      heightFactor: 1,
      child: Padding(
        padding: EdgeInsets.only(
          top: 100,
          left: 50,
          right: 50,
        ),
        child: Container(
          width: width,
          height: 800,
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
                Color.fromARGB(226, 160, 0, 0),
                Color.fromARGB(239, 146, 146, 146),
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
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Przegrałes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            titleFontSize, // Dynamiczny rozmiar tekstu tytułu
                        fontFamily: 'CrayonPaperDemoRegular',
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        'Niestety nie udało ci się ;c.\n Pamiętaj, że zawsze możesz spróbować ponownie!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: textFontSize, // Dynamiczny rozmiar tekstu
                        ),
                      ),
                    ),
                    Lottie.network(
                      'https://raw.githubusercontent.com/patrykkostecki/rapDLE/main/assets/LossAnimation.json',
                      repeat: false,
                    ),
                    Text(
                      'Nazwa piosenki to:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: textFontSize,
                      ),
                    ),
                    Text(
                      songName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            songFontSize, // Dynamiczny rozmiar tekstu piosenki
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: onRetry,
                      child: Container(
                        height: 50.0,
                        width: 200.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(210, 10, 0, 95),
                              Color.fromARGB(210, 15, 0, 150),
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
                            color: Color.fromARGB(255, 0, 0, 0),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'Spróbuj ponownie',
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
