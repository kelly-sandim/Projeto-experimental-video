import 'dart:io';
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
import 'package:geolocator/geolocator.dart';
import 'package:get_ip/get_ip.dart';

class VideoPlayerPage extends StatefulWidget {
  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {  
  String videoTitle;
  VideoPlayerController controllerVideo;
  String userId;
  String videoId;  
  String messageError;  
  bool isLoading = true;

  _getData(_initVideo) async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      videoId = prefs.getString('videoId');      
    });

    _initVideo();
  }

  _initVideo() async
  {
    var responseVideo = await new VideoApi().getVideo(videoId, userId);
    var response = jsonDecode(responseVideo.toString());
    print(response);
    if(response['status'] != 200)
    {
      setState(() {
        messageError = response['error'];
        _showDialog();
      });
    }
    else
    {      
      controllerVideo = VideoPlayerController.network(response['video_url']);

      controllerVideo.addListener(() {
        setState(() {});
      });    
      controllerVideo.setLooping(false);
      controllerVideo.initialize().then((_) => setState(() {}));

      setState(() {
        videoTitle = response['titulo_video'];
      });   
    }
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
              child: new Text("OK"),
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
    _getData(_initVideo);
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    controllerVideo.dispose();

    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Video Player", style: TextStyle(color: MyColors.grey)),        
        backgroundColor: MyColors.white,
        elevation: 0.0, //para tirar a sombra
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },          
          child: isLoading ? CircularProgressIndicator()
          : SingleChildScrollView(
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
                  child: Text(
                    videoTitle,
                    style: TextStyle(color: MyColors.grey, fontWeight: FontWeight.bold, fontSize: 25),
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
