import 'package:flutter/material.dart';
import './size_config.dart';
//import 'dart:io';
import 'package:universal_io/io.dart';
import 'dart:convert';
import 'dart:async';



Socket? socket;
Stream<List<int>>? stream;
List<String> messages = [];
List<String> player=[];
String your_theme = "";
bool game_start = false;
int player_number = 0;
List<int> already_last = []; 



Future<void> estateSocket(Socket s, String name) async{
  socket = s;
  stream = socket?.asBroadcastStream();
  player.add(name + "   (You)");
  player_number = player.length;
}

Future<void> sendMessage(String message) async {
    socket?.writeln(message.trim());
    print("send");
    await Future.delayed(Duration(milliseconds: 10));
}

Future<void> recieveMessage() async{
  String message;
  List<String> message_split;
  stream?.listen((List<int> event) {
    if(event != already_last){
      already_last = event;
      print(utf8.decode(event));
      message = utf8.decode(event);
      message_split = message.split(' ');
      bool playerlist = false;
      for (int i = 0; i < message_split.length; i++){
        if (message_split[i].contains("VOTE")){
          messages.add("投票開始です。プレイヤーidを入力してください");
          break;
        }
        if (message_split.contains("JOIN")){
          if (i < message_split.length-1){
            player.add(message_split[i+1].trim() + "  (id:" + (player_number).toString() +")");
            messages.add(message_split[i+1].trim() + "が入室しました");
            player_number  = player.length;
            break;
          }
        }
        if (message_split[i] == "REMOVE"){
          if (i < message_split.length-2){
            player.remove(message_split[i+1].trim() + "  (id:" + (message_split[i+2]).trim() +")");
            messages.add(message_split[i+1].trim() + "が退室しました");
            player_number -= 1;
            break;
          }
        }
        if (message_split[i] == "PLAYER_LIST"){
          playerlist = true;
          continue;
        }
        if (message_split[i].contains("END")){
          playerlist = false;
          continue;
        } else if (playerlist){
          player.add(message_split[i].trim() + "  (id:" + (player_number-1).toString() +")");
          player_number = player.length;
          continue;
        }
        if(message_split[i] == "START"){
          messages.add("ゲームスタート");
          game_start = true;
          continue;
        }
        if(message_split[i].contains("RESTART")){
          messages.add("同数であったため再び話し合いの時間です");
          game_start = true;
          break;
        }
        if (message_split[i].contains("THEME")){
          if (i < message_split.length-1){
            your_theme = message_split[i+1].trim();
            messages.add("あなたのお題は"+message_split[i+1].trim()+"です。話し合いを始めてください");
          }
          break;
        }
        if (message_split[i].contains("ALREADY_STARTED")){
          messages.add("すでにゲームが始まっています。");
          break;
        }
        if (message_split[i].contains("SELECTED")){
          if (i < message_split.length-2){
            messages.add(message_split[i+1].trim()+"が選ばれました。");
            if (message_split[i+2].contains("WIN")){
              messages.add("勝利！！");
              break;
            }
            if (message_split[i+2].contains("LOSE")){
              messages.add("敗北...");
              break;
            }
          }
          break;
        }
        if (message_split[i].contains(":")){
          if (i < message_split.length-1){
            messages.add(message);
            break;
          }
        }
      }
    }
    });

  
}


class Game extends StatelessWidget {
  final Socket socket;
  final String name;
  const Game({Key? key, required this.socket, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    estateSocket(socket, name);
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
  final ScrollController _scrollController = ScrollController(                        
      initialScrollOffset: 0.0,                                       
      keepScrollOffset: true,                                       
    );

  void _toEnd() {                                                    
    _scrollController.animateTo(                                      
      _scrollController.position.maxScrollExtent,                     
      duration: const Duration(milliseconds: 500),                    
      curve: Curves.ease,                                             
    );                                                                
  }

  
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


  void recieveThread() async{
    Timer? timer;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState((){
        recieveMessage();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
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
                height: SizeConfig.blockSizeVertical! * 7,
                width: SizeConfig.blockSizeHorizontal! * 80,
                color: Colors.pink[200],
                child:Column(children: [
                const Text("Your theme"),
                Text(your_theme),
                ],)
            ),
            Container(  
                height: SizeConfig.blockSizeVertical! * 13,
                width: SizeConfig.blockSizeHorizontal! * 80,
                color: Colors.cyan[100],
                child:Column(children: [
                  const Text("PlayerNumber"),
                  Text(player_number.toString()),
                  Flexible(child: Scrollbar(
                    controller: _scrollController,
                    child:SingleChildScrollView( 
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,             
                      children: [
                      ...player.map((element) => ListTile(title: Text(element))),
                      ],
                    )
                    )
                  ))
                ],) 
            ),
            Expanded(child:SingleChildScrollView( 
              controller: _scrollController,
              child:Column(
                children: [
                  ...messages.map((element) => ListTile(title: Text(element))),
                ],
              ),
            )),
            Container(
              height: SizeConfig.blockSizeVertical! * 8,
              width: SizeConfig.blockSizeHorizontal! * 80,
              color: Colors.grey[100],
              child:IconButton(
                onPressed: _toEnd,
                icon: Icon(Icons.arrow_downward),
              )
            ),
          ],
        ),
      );
  }
}


