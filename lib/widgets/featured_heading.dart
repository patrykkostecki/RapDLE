// import 'package:rapdle/widgets/responsive.dart';
import 'package:flutter/material.dart';

class FeaturedHeading extends StatelessWidget {
  const FeaturedHeading({
    Key? key,
    required this.screenSize,
  }) : super(key: key);

  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: screenSize.height * 0.06,
        left: screenSize.width / 15,
        right: screenSize.width / 15,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Najnowsze plyty',
            style: TextStyle(
                fontSize: 36,
                fontFamily: 'MiniBananaDemoRegular',
                fontWeight: FontWeight.bold,
                color: Color(0xFF000000)),
          ),
          Expanded(
            child: Text(
              'Dodane',
              textAlign: TextAlign.end,
              style:
                  TextStyle(fontFamily: 'MiniBananaDemoRegular', fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
