import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';


Socket? socket;
List<String> messages = [];

Future<void> connect() async {
    try {
      socket = await Socket.connect('10.65.231.73', 1234);
      print("connect");
    } catch (e) {
      throw Exception('connect error!!');
    }
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

/*Future<void> recieveThread() async{
 Timer? timer;
  timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
    recieveMessage();
  });
}
*/

void main() {
  connect();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Wolf',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Word Wolf Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{
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
      body: Column(
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
    );
  }
}
