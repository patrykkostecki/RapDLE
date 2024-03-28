import 'package:flutter/material.dart';
import 'package:rapdle/widgets/responsive.dart';

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
    final screenSize = MediaQuery.of(context).size;
    return Center(
      heightFactor: 1,
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
                  'Przegrałeś',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: screenSize.height / 20),
                Image.network(
                  imagePath,
                  width: 300,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: screenSize.height / 20),
                Text(
                  songName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: screenSize.height / 20),
                ElevatedButton(
                  onPressed: onRetry,
                  child: Text('Spróbuj ponownie'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
