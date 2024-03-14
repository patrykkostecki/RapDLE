import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize; // dodaj to

  CustomAppBar({
    Key? key,
  })  : preferredSize =
            Size.fromHeight(60.0), // Tutaj ustaw preferowaną wysokość AppBar
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: Color(0xFFFFDABA),
      elevation: 0,
    );
  }
}
