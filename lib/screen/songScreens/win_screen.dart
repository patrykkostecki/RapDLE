import 'package:flutter/material.dart';
import 'package:rapdle/widgets/responsive.dart';
import 'package:lottie/lottie.dart';

class WinScreen extends StatelessWidget {
  final String songName;
  final String imagePath;
  final VoidCallback onRetry;
  final Duration timeRemaining;

  const WinScreen({
    Key? key,
    required this.songName,
    required this.imagePath,
    required this.onRetry,
    required this.timeRemaining,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(
            top: ResponsiveWidget.isSmallScreen(context)
                ? screenSize.height / 12
                : screenSize.height / 5,
            left: ResponsiveWidget.isSmallScreen(context)
                ? screenSize.width / 12
                : screenSize.width / 5,
            right: ResponsiveWidget.isSmallScreen(context)
                ? screenSize.width / 12
                : screenSize.width / 5,
          ),
          child: Card(
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(screenSize.height / 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Wygrałeś',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: screenSize.height / 20),
                  Lottie.asset('WinAnimation.json', repeat: false),
                  SizedBox(height: screenSize.height / 20),
                  Text(
                    songName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: screenSize.height / 20),
                  Text(
                    'Czas do kolejnej piosenki: ${timeRemaining.inMinutes} minut',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: screenSize.height / 20),
                  ElevatedButton(
                    onPressed: timeRemaining.inSeconds <= 0 ? onRetry : null,
                    child: Text('Kolejna Piosenka!'),
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
