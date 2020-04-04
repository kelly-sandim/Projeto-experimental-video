import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'package:video_player/video_player.dart';

import '../../../../src/assets/colors/MyColors.dart';
import '../api/VideoApi.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SendVideo extends StatefulWidget {
  @override
  _SendVideoState createState() => _SendVideoState();
}

class _SendVideoState extends State<SendVideo> {  
  TextEditingController controllerTitle = new TextEditingController();
  TextEditingController controllerDescription = new TextEditingController();
  VideoPlayerController controllerVideo;
  String videoPath;

  _getData(_initVideo) async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      controllerTitle.text = prefs.getString('videoName');
      videoPath = prefs.getString('videoPath');     
    });

    _initVideo();
  }

  _initVideo()
  {
    controllerVideo = VideoPlayerController.network(videoPath);

    controllerVideo.addListener(() {
      setState(() {});
    });
    controllerVideo.setLooping(true);
    controllerVideo.initialize().then((_) => setState(() {}));
    controllerVideo.play();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);    
    _getData(_initVideo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Adicionar detalhes", style: TextStyle(color: MyColors.grey)),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.send, size: 40, color: MyColors.grey), 
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/WaitAnalysis');
            }),          
        ],
        backgroundColor: MyColors.white,
        elevation: 0.0, //para tirar a sombra
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },          
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: controllerVideo.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        VideoPlayer(controllerVideo),
                        _PlayPauseOverlay(controller: controllerVideo),
                        VideoProgressIndicator(controllerVideo, allowScrubbing: true),
                      ],
                    ),
                  ),
                ),
                Container(                
                  margin: EdgeInsets.only(top: 25.0),
                  width: MediaQuery.of(context).size.width / 1,
                  padding:
                      EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: MyColors.white,
                      ),
                  child: TextFormField(
                    enabled: false,
                    controller: controllerTitle,
                    decoration: InputDecoration(                        
                        hintText: 'Título',
                        border: new UnderlineInputBorder(
                          borderSide: new BorderSide(
                            color: MyColors.grey 
                          ),
                        ), 
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1,
                  margin: EdgeInsets.only(top: 20),
                  padding:
                      EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: MyColors.white,
                      ),
                  child: TextField(
                    controller: controllerDescription, 
                    keyboardType: TextInputType.multiline,
                    maxLines: null,                   
                    decoration: InputDecoration(                        
                        hintText: 'Descrição',
                        border: new UnderlineInputBorder(
                          borderSide: new BorderSide(
                            color: MyColors.grey 
                          ),
                        ),                   
                      ),
                    ),
                  ),
                
              ],
            ),
          ),      
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
