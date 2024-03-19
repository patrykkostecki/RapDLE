import 'package:flutter/material.dart';
import 'screen/home_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAcqmDgpGj2ehT7nnlC1tpRp8yu31kkS50",
      authDomain: "rapdle.firebaseapp.com",
      projectId: "rapdle",
      storageBucket: "rapdle.appspot.com",
      messagingSenderId: "11241716983",
      appId: "1:11241716983:web:79b6e38d410174410127f2",
      measurementId: "G-XRZFEZQL4H",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
