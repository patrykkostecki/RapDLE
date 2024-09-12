import 'package:flutter/material.dart';
import 'package:rapdle/widgets/bottom_bar_column.dart';
import 'package:rapdle/widgets/info_text.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
  });

  static const Color gradientStartColor = Color(0xff424C55);
  static const Color gradientEndColor = Color(0xffC9C5CA);

  @override
  Widget build(BuildContext context) {
    // Sprawdza szerokość ekranu, aby ustalić, czy to telefon czy komputer
    bool isSmallScreen = MediaQuery.of(context).size.width < 800;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: gradientStartColor,
            offset: Offset(1.0, 6.0),
            blurRadius: 1.0,
          ),
          BoxShadow(
            color: gradientEndColor,
            offset: Offset(1.0, 6.0),
            blurRadius: 1.0,
          ),
        ],
        gradient: LinearGradient(
            colors: [gradientStartColor, gradientEndColor],
            begin: const FractionalOffset(0.2, 0.2),
            end: const FractionalOffset(1.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      padding: EdgeInsets.all(30),
      child: Column(
        children: [
          // W zależności od szerokości ekranu układ zmienia się na kolumnę (na telefonach) lub wiersz (na komputerach)
          isSmallScreen
              ? Column(
                  // Dla małych ekranów układ pionowy (kolumna)
                  children: [
                    BottomBarColumn(
                      heading: 'rapDLE - guess rap song!',
                      s1: 'Contact Us',
                      s2: 'About Us',
                      s3: 'Careers',
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoText(
                          type: 'Email',
                          text: 'rapdle@gmail.com',
                        ),
                        SizedBox(height: 5),
                        InfoText(
                          type: 'Adres',
                          text: 'Katowice',
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  // Dla dużych ekranów układ poziomy (wiersz)
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    BottomBarColumn(
                      heading: 'rapDLE - guess rap song!',
                      s1: 'Contact Us',
                      s2: 'About Us',
                      s3: 'Careers',
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoText(
                          type: 'Email',
                          text: 'rapdle@gmail.com',
                        ),
                        SizedBox(height: 5),
                        InfoText(
                          type: 'Adres',
                          text: 'Katowice',
                        ),
                      ],
                    ),
                  ],
                ),
          Divider(
            color: Colors.white,
          ),
          SizedBox(height: 20),
          Text(
            'Copyright © 2024 | Essa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
