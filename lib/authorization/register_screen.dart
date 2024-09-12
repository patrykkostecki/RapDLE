import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final VoidCallback onRegister;

  const RegisterScreen({Key? key, required this.onRegister}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          width: 400, // Ustaw szerokość dla ekranu rejestracji
          height: 450, // Ustaw wysokość dla ekranu rejestracji
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
                Color.fromARGB(236, 255, 255, 255),
                Color.fromRGBO(161, 161, 161, 0.922),
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
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Rejestracja',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nazwa uzytkownika',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Hasło',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Powtórz Hasło',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: onRegister,
                      child: Text('Zarejestruj się'),
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
