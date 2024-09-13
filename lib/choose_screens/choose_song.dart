import 'package:flutter/material.dart';

class SongOptionsWidget extends StatelessWidget {
  final VoidCallback onDailySongSelected;
  final VoidCallback onSongGuesserSelected;

  SongOptionsWidget({
    required this.onDailySongSelected,
    required this.onSongGuesserSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 150, left: 20.0, right: 20.0),
        child: Container(
          width: 400,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(251, 39, 39, 39),
              width: 4,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFAC8115).withOpacity(0.4),
                spreadRadius: 20,
                blurRadius: 60,
                offset: Offset(0, 2),
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
            borderRadius: BorderRadius.circular(30),
            child: Card(
              margin: EdgeInsets.zero,
              color: Colors.transparent,
              elevation: 20,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton(context, 'Daily Song', Colors.grey, true),
                    SizedBox(height: 20),
                    _buildButton(context, 'Song Guesser', Colors.grey, false),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String label, Color color, bool isDailySong) {
    return ElevatedButton(
      onPressed: () {
        if (isDailySong) {
          onDailySongSelected(); // Wywołanie callbacku dla Daily Song
        } else {
          onSongGuesserSelected(); // Wywołanie callbacku dla Song Guesser
        }
      },
      child: Container(
        height: 50.0,
        width: 200.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.7),
              color.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 17, 17, 17).withOpacity(0.8),
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
          label,
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
    );
  }
}
