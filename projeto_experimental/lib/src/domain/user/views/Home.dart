import 'dart:ui';
import 'dart:io' as Io;
import 'dart:async';
import 'dart:convert';

import 'package:video_player/video_player.dart';
import '../../../../src/assets/colors/MyColors.dart';
import '../../videos/api/VideoApi.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  TabController tabController; 

  var jsonData;
 
  String messageError;
  bool isLoading = true;
  var userId;

  List<Widget> tabList(BuildContext context) {
    List<Widget> _tabList = [
      isLoading
        ? Center(
            child: CircularProgressIndicator(
              strokeWidth: 8,
              valueColor:
                  new AlwaysStoppedAnimation<Color>(MyColors.primaryColor)),
          )
        : Container(
            color: MyColors.white,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: new ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: jsonData == null ? 0 : jsonData.length,
                      itemBuilder: (BuildContext context, int index) {
                        var videoId = jsonData[index]['Id do Video'];
                        var videoName = jsonData[index]['Nome do Video'];
                        var videoDate = jsonData[index]['Data do Video'];
                        var mediaVoice = jsonData[index]['Media Voz'];
                        var mediaImage = jsonData[index]['Media Imagem'];
                        var mediaText = jsonData[index]['Media Texto'];
                        
                        return Card(
                          child: Column(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  new ListTile(
                                    leading: Icon(Icons.play_circle_filled,
                                        color: MyColors.primaryColor, size: 50),
                                    title: Text("$videoName\n", style: TextStyle(
                                                  fontSize: 20, 
                                                  color: MyColors.primaryColor,
                                                  fontWeight: FontWeight.bold, 
                                                ),),
                                    subtitle: RichText(
                                        text: TextSpan(
                                          text: "Postado em: $videoDate\n\n",
                                          style: TextStyle(
                                                    fontSize: 20, 
                                                    color: MyColors.grey,
                                                    fontWeight: FontWeight.bold, 
                                                  ),
                                          children: [
                                            TextSpan(text: "Média das Vozes: ", style: TextStyle(fontSize: 15, color: MyColors.grey, fontWeight: FontWeight.bold)),
                                            WidgetSpan(child: mediaVoice),
                                            TextSpan(text: "\n"),
                                            TextSpan(text: "Média das Imagens: ", style: TextStyle(fontSize: 15, color: MyColors.grey, fontWeight: FontWeight.bold)),
                                            WidgetSpan(child: mediaImage),
                                            TextSpan(text: "\n"),
                                            TextSpan(text: "Média dos Textos: ", style: TextStyle(fontSize: 15, color: MyColors.grey, fontWeight: FontWeight.bold)),
                                            WidgetSpan(child: mediaText),                                            
                                            TextSpan(text: "\n"),
                                          ],
                                        ),
                                      ), 
                                    onTap: () {
                                      
                                    },
                                  ),
                                  ButtonTheme(                                    
                                    child: ButtonBar(
                                      alignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        FlatButton(
                                          child: const Text('VER RESULTADO DA ANÁLISE',
                                          style: TextStyle(color: MyColors.primaryColor, fontSize: 15.0),
                                          ),
                                          onPressed: () {
                                            _setDataToResultPage(videoId, _callResultPage);
                                          },
                                        ),
                                        FlatButton(
                                          child: const Text('ASSISTIR VÍDEO',
                                          style: TextStyle(color: MyColors.primaryColor, fontSize: 15.0),
                                          ),
                                          onPressed: () {
                                            _setDataToVideoPlayerPage(videoId, _callVideoPlayerPage);
                                          },
                                        ),
                                      ],
                                    ),
                                  ), 
                                ],
                              )
                            ],
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        Container(
          color: MyColors.white,
          child: ListView(
            children: <Widget>[
              new ListTile(
                title: new Text(
                  "Logout",
                  style: TextStyle(
                      color: MyColors.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                leading: new Icon(Icons.power_settings_new,
                    color: MyColors.primaryColor, size: 30),
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.clear();
                  Navigator.pushReplacementNamed(context, '/LoginPage');
                },
              ),
              new Divider(),
            ],
          )),
    ];

    return _tabList;
  }

  _setDataToResultPage(var videoId, _callResultPage) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('videoId', videoId);

    _callResultPage();
  }

  _callResultPage()
  {
    Navigator.pushNamed(context, '/Result');
  }

  _setDataToVideoPlayerPage(var videoId, _callVideoPlayerPage) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('videoId', videoId);

    _callVideoPlayerPage();
  }

  _callVideoPlayerPage()
  {
    //Navigator.pushNamed(context, '/Result');
  }

  _loadData(_loadVideoList) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
    _loadVideoList(userId);  
  }

  _loadVideoList(var userId) async {    
    var responseGet = await new VideoApi().getAllVideoData(userId);
    var response = jsonDecode(responseGet.toString());

    print(response);

    if (response['status'] != 200) {
      setState(() {
        messageError = response['error'];
        _showDialog();
      });
    } else {
        var dataD;
        var dataE; 
        var dataF; 
        var jsonEntry = new List();

        for (var item in response['data']) {
          var videoData = {};
          var dataA = item['id'];
          DateTime dateTime = DateFormat("yyyy-MM-dd hh:mm").parse(item['date_created']);
          var dataB = "${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute}";        
          var dataC = item['nome'];
          var mediaVoice = item['medias_voice'];
          if((mediaVoice) < 0.33)
          {
            dataD = Image.asset('./lib/src/assets/images/frowning-face.png', width: 35, height: 35);
          }
          else if((mediaVoice) >= 0.33 && (mediaVoice) < 0.6)
          {
            dataD = Image.asset('./lib/src/assets/images/neutral-face.png', width: 35, height: 35);
          }
          else
          {
            dataD = Image.asset('./lib/src/assets/images/smiling-face.png', width: 35, height: 35);
          }

          var mediaImage = item['medias_image'];        
          if((mediaImage) < 0.33)
          {
            dataE = Image.asset('./lib/src/assets/images/frowning-face.png', width: 35, height: 35);
          }
          else if((mediaImage) >= 0.33 && (mediaImage) < 0.6)
          {
            dataE = Image.asset('./lib/src/assets/images/neutral-face.png', width: 35, height: 35);
          }
          else
          {
            dataE = Image.asset('./lib/src/assets/images/smiling-face.png', width: 35, height: 35);
          }

          var mediaText = item['medias_text'];        
          if((mediaText) < 0.33)
          {
            dataF = Image.asset('./lib/src/assets/images/frowning-face.png', width: 35, height: 35);
          }
          else if((mediaText) >= 0.33 && (mediaText) < 0.6)
          {
            dataF = Image.asset('./lib/src/assets/images/neutral-face.png', width: 35, height: 35);
          }
          else
          {
            dataF = Image.asset('./lib/src/assets/images/smiling-face.png', width: 35, height: 35);
          }

          videoData.addAll({'Id do Video':dataA, 'Data do Video':dataB, 'Nome do Video':dataC, 'Media Voz':dataD, 'Media Imagem':dataE, 'Media Texto':dataF});
          jsonEntry.add(videoData);
        }//fim for

        jsonData = jsonEntry;
    }//fim else
    setState(() {
      isLoading = false;
    });
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Erro!"),
          content: new Text(messageError),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK", style: TextStyle(color: MyColors.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);    
    tabController = TabController(vsync: this, length: 2);
    _loadData(_loadVideoList);
  }

  @override
  void dispose() {
    tabController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: Image.asset('./lib/src/assets/images/youtube.png',
            fit: BoxFit.cover, height: 35),
        title: Text("YouFace", style: TextStyle(color: MyColors.grey)),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.videocam, size: 40, color: MyColors.grey),
              onPressed: () {
                Navigator.pushNamed(context, '/RecordVideo');
              }),
        ],
        backgroundColor: MyColors.white,
        elevation: 0.0, //para tirar a sombra
      ),
      body: TabBarView(
        controller: tabController,
        children: tabList(context),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          tabController.animateTo(currentIndex);
        },
        items: [
          BottomNavigationBarItem(
            title: Text("Meus vídeos",
                style: TextStyle(
                    color: currentIndex == 0
                        ? MyColors.primaryColor
                        : MyColors.grey,
                    fontSize: 18)),
            icon: Icon(Icons.video_library, color: MyColors.grey),
            activeIcon: Icon(Icons.video_library, color: MyColors.primaryColor),
          ),
          BottomNavigationBarItem(
            title: Text("Configurações",
                style: TextStyle(
                    color: currentIndex == 1
                        ? MyColors.primaryColor
                        : MyColors.grey,
                    fontSize: 18)),
            icon: Icon(Icons.settings, color: MyColors.grey),
            activeIcon: Icon(Icons.settings, color: MyColors.primaryColor),
          )
        ],
      ),
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
