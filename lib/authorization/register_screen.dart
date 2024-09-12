import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegister;

  const RegisterScreen({Key? key, required this.onRegister}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String errorMessage = '';

  Future<void> _register() async {
    if (password == confirmPassword) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Dodanie nazwy użytkownika do Firestore
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'username': username,
          'email': email,
        });

        widget.onRegister();
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
      }
    } else {
      setState(() {
        errorMessage = "Hasła nie pasują.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          width: 400,
          height: 500,
          decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(251, 39, 39, 39),
              width: 4,
            ),
            borderRadius: BorderRadius.circular(30),
            gradient: RadialGradient(
              colors: [
                Color.fromARGB(236, 255, 255, 255),
                Color.fromRGBO(161, 161, 161, 0.922)
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
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Rejestracja',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 35)),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Nazwa użytkownika',
                          border: OutlineInputBorder()),
                      onChanged: (value) {
                        setState(() {
                          username = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Email', border: OutlineInputBorder()),
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Hasło', border: OutlineInputBorder()),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Powtórz Hasło',
                          border: OutlineInputBorder()),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          confirmPassword = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _register,
                      child: Text('Zarejestruj się'),
                    ),
                    if (errorMessage.isNotEmpty)
                      Text(errorMessage, style: TextStyle(color: Colors.red)),
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
