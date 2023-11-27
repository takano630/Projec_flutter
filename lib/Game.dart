import 'package:flutter/material.dart';
import './size_config.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

Socket? socket;
List<String> messages = [];
List<String> player=[];
bool game_start = false;



Future<void> estateSocket(Socket s) async{
  socket = s;
}

Future<void> sendMessage(String message) async {
    socket?.writeln(message.trim());
    print("send");
    await Future.delayed(Duration(milliseconds: 10));
}

Future<void> recieveMessage() async{
  String message;
  List<String> message_split;
  try{

  socket?.listen((List<int> event) {
      print(utf8.decode(event));
      message = utf8.decode(event);
      message_split = message.split(' ');
      for (int i = 0; i < message_split.length-1; i++){
        if (message_split[i] == "JOIN"){
          player.add(message_split[i+1].trim());
          messages.add(message_split[i+1].trim() + "が入室しました");
          break;
        }
      }
      if (message.contains("ENTER_NAME")){
        messages.add("名前を入力してください");
      } else if(message.contains("START")){
        messages.add("ゲームスタート");
        game_start = true;
      } else {
        messages.add(message);
      }
    });
  }catch (e) {
      throw Exception('error!!');
  }
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
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState((){
        recieveMessage();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    recieveThread();
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body:Column(
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
            Container(  
                height: SizeConfig.blockSizeVertical! * 15,
                width: SizeConfig.blockSizeHorizontal! * 80,
                color: Colors.cyan[100],
                child:Column(children: [
                  const Text("PlayerList"),
                  Flexible(child:SingleChildScrollView( 
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,             
                      children: [
                      ...player.map((element) => ListTile(title: Text(element))),
                      ],
                    )
                  ))
                ],) 
            ),
            Expanded(child:SingleChildScrollView( 
              child:Column(
                children: [
                  ...messages.map((element) => ListTile(title: Text(element))),
                ],
              ),
            ))
          ],
        ),
      );
  }
}


