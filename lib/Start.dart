import 'package:flutter/material.dart';
import 'package:project_flutter/Connect.dart';
import 'dart:io';
import 'dart:async';


class Start extends StatelessWidget {
  const Start({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Wolf',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StartPage(title: 'Start Page'),
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key, required this.title});
  final String title;

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>{
  String ip = "";

  void _start() async{
    await new Future.delayed(new Duration(seconds: 2));
    Navigator.of(context).push(MaterialPageRoute(builder:(context) => Connect()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[100],
      body: Center( 
        child : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('images/wordwolftitle.png'),
            ElevatedButton(
              child: const Text('START'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.purple[300],
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
              onPressed: _start,
            ),
          ],
        ),
      )
    );
  }
}

