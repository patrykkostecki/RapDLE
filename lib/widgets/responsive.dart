import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget largeScreen; // Widget dla dużych ekranów
  final Widget? mediumScreen; // Widget dla średnich ekranów
  final Widget? smallScreen; // Widget dla małych ekranów (telefonów)

  const ResponsiveWidget({
    Key? key,
    required this.largeScreen,
    this.mediumScreen,
    this.smallScreen,
  }) : super(key: key);

  // Sprawdza, czy ekran jest mały (np. telefon)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  // Sprawdza, czy ekran jest duży (np. komputer)
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200;
  }

  // Sprawdza, czy ekran jest średni (np. tablet)
  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800 &&
        MediaQuery.of(context).size.width <= 1200;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isLargeScreen(context)) {
          // Dla dużych ekranów, używaj largeScreen
          return largeScreen;
        } else if (isMediumScreen(context)) {
          // Dla średnich ekranów, jeśli podano mediumScreen, w przeciwnym razie largeScreen
          return mediumScreen ?? largeScreen;
        } else {
          // Dla małych ekranów (telefonów), jeśli podano smallScreen, w przeciwnym razie largeScreen
          return smallScreen ?? largeScreen;
        }
      },
    );
  }
}
