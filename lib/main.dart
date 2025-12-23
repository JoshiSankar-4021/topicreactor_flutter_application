import 'package:flutter/material.dart';
import 'TopicCreator.dart';
import 'homescreen.dart';
import 'login.dart';
import 'Register.dart';
import 'Topics.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      initialRoute:'/',
      routes: {
        '/':(context)=>Login(),
        '/home':(context)=>HomeScreen(),
        '/register':(context)=>Register(),
        '/topic creator':(context)=>TopicCreator(),
        '/topics':(context)=>Topics()
      },
    );
  }
}







