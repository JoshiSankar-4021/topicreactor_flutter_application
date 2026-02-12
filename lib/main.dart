import 'package:flutter/material.dart';
import 'TopicCreator.dart';
import 'homescreen.dart';
import 'login.dart';
import 'Register.dart';
import 'Topics.dart';
import 'TopicListScreen.dart';
import 'utils/SessionManager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Topic Reactor',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Login(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const Register(isUpdate: false), // fixed
        '/topiccreator': (context) => const TopicCreator(),
        '/topics': (context) => const Topics(),
        '/profile': (context) => const Register(isUpdate: true), // reuse register as profile update
        '/mytopics':(context) => const TopicList()
      },
    );
  }
}
