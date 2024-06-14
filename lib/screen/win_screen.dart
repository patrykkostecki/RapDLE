import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WinScreen extends StatelessWidget {
  final String songName;
  final String imagePath;
  final VoidCallback onRetry;

  const WinScreen({
    Key? key,
    required this.songName,
    required this.imagePath,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: Padding(
        padding: EdgeInsets.only(
          top: 100, // Stała wartość dla górnego paddingu
          left: 50, // Stała wartość dla lewego paddingu
          right: 50, // Stała wartość dla prawego paddingu
        ),
        child: Container(
          width: 800,
          height: 800, // Zmieniona wysokość na mniejszą
          decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(251, 39, 39, 39),
              width: 4,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFAC8115).withOpacity(0.4),
                spreadRadius:
                    30, // SpreadRadius większy, aby przypominał pierwsze okno
                blurRadius:
                    100, // BlurRadius większy, aby przypominał pierwsze okno
                offset: Offset(0, 2),
              ),
            ],
            gradient: RadialGradient(
              colors: [
                Color.fromARGB(230, 10, 82, 0),
                Color.fromARGB(225, 146, 146, 146),
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
                      'Wygrałes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 45,
                        fontFamily: 'CrayonPaperDemoRegular',
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                              30.0), // Adjust horizontal padding as needed
                      child: Text(
                        'Gratulacje! Udało Ci się odgadnąć piosenkę.\nSpróbuj odgadnąć kolejną jutro!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Lottie.network(
                      'https://raw.githubusercontent.com/patrykkostecki/rapDLE/main/assets/WinAnimation.json',
                      repeat: false,
                    ),
                    Text(
                      'Taaaaaak! Jest to:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      songName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
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
                            color: Color.fromARGB(172, 32, 32, 32),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'Kolejna Piosenka!',
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
