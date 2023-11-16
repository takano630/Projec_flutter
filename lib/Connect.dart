import 'package:flutter/material.dart';
import 'package:project_flutter/Game.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';


Socket? socket;

Future<void> connect(String ip) async {
    try {
      socket = await Socket.connect(ip, 1234);
      print("connect");
    } catch (e) {
      throw Exception('connect error!!');
    }
}

Socket? returnSocket() {
  return socket;
}

Future<void> sendMessage(String message) async {
    socket?.writeln(message);
    print("send");
    await Future.delayed(Duration(milliseconds: 10));
}


class Connect extends StatelessWidget {
  const Connect({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Wolf',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ConnectPage(title: 'Connect Page'),
    );
  }
}

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key, required this.title});
  final String title;

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage>{
  String ip = "";

  void _sendconnect(){
    if (ip!=""){
      connect(ip);
      Navigator.of(context).push(MaterialPageRoute(builder:(context) => Game(socket: returnSocket() as Socket)
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    print("connectpage");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          TextField(
                maxLength: 50,
                maxLines:1,
                decoration: InputDecoration (                  
                  suffixIcon: IconButton(
                    onPressed: _sendconnect,
                    icon: Icon(Icons.send),
                  ),
                ),
                onChanged: (String txt)=> ip = txt,
              ),
        ],
      ),
    );
  }
}
