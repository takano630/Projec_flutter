import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:project_flutter/Connect.dart';

Socket? socket;
List<String> messages = [];

Future<void> estateSocket(Socket s) async{
  socket = s;
}

Future<void> sendMessage(String message) async {
    socket?.writeln(message);
    print("send");
    await Future.delayed(Duration(milliseconds: 10));
    messages.add("you:" + message);
}

Future<void> recieveMessage() async{
  String message;
  socket?.listen((List<int> event) {
      print(utf8.decode(event));
      message = utf8.decode(event);
      messages.add(message);
    });
}


class Game extends StatelessWidget {
  final Socket socket;
  const Game({Key? key, required this.socket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    estateSocket(socket);
    return MaterialApp(
      title: 'Word Wolf',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GamePage(title: 'Word Wolf Home Page'),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.title});

  final String title;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>{
  String sendtext = "";
  var _controller = TextEditingController();

  
  void _sendrecieve() {
    setState(() {
      _controller.clear();
      if (sendtext != ""){
        sendMessage(sendtext);
        sendtext = "";
        print(messages);
      }
      recieveMessage();
    });
  }

  void recieveThread() {
    Timer? timer;
    timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      setState((){
        recieveMessage();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    recieveThread();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body:SingleChildScrollView( 
        child:Column(
          children: [
            TextField(
                  maxLength: 50,
                  maxLines:1,
                  controller: _controller,
                  decoration: InputDecoration (                  
                    suffixIcon: IconButton(
                      onPressed: _sendrecieve,
                      icon: Icon(Icons.send),
                    ),
                  ),
                  onChanged: (String txt)=> sendtext = txt,
                ),
            ...messages.map((element) => ListTile(title: Text(element))),
          ],
        ),
      ),
    );
  }
}

