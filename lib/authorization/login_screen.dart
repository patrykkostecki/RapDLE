import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;

  const LoginScreen({Key? key, required this.onLogin}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  String errorMessage = '';

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      widget.onLogin();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
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
          height: 400,
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
                    Text('Logowanie',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 35)),
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
                    ElevatedButton(
                      onPressed: _login,
                      child: Text('Zaloguj się'),
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
