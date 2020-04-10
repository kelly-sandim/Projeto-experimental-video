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

class SendVideo extends StatefulWidget {
  @override
  _SendVideoState createState() => _SendVideoState();
}

class _SendVideoState extends State<SendVideo> {  
  TextEditingController controllerTitle = new TextEditingController();
  TextEditingController controllerDescription = new TextEditingController();
  VideoPlayerController controllerVideo;
  File videoFile;
  String videoPath;
  String userId;
  String base64Video = "";
  String messageError;

  _getData(_initVideo) async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      controllerTitle.text = prefs.getString('videoName');
      videoPath = prefs.getString('videoPath'); 
      videoFile = new File(videoPath);    
    });

    _initVideo();
  }

  _initVideo()
  {
    controllerVideo = VideoPlayerController.network(videoPath);

    controllerVideo.addListener(() {
      setState(() {});
    });    
    controllerVideo.setLooping(false);
    controllerVideo.initialize().then((_) => setState(() {}));    
  }

  _uploadVideo(_callWaitAnalysis) async
  {  
    var isLoading = true;

    isLoading ? showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width /2.5,
            height:  70,
            child:
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                new Padding(padding: EdgeInsets.only(right: 10.0)),
                new CircularProgressIndicator(),
                new Padding(padding: EdgeInsets.only(right: 26.0)),
                new Text("Enviando o vídeo,\n por favor, aguarde..."),
              ],
            ),
          ),
        );
      },
    ) : Offstage();
    
    if (videoFile != null)
    {
      setState(() {        
        base64Video = base64Encode(videoFile.readAsBytesSync());
        print(base64Video);
      });
    }

    var currentLocation = await Geolocator().getCurrentPosition();
    var lat = currentLocation.latitude;
    var lng = currentLocation.longitude;
    var ip = await GetIp.ipAddress;

    var responseUpload = await new VideoApi().uploadVideo(userId, controllerTitle.text, base64Video, lat, lng, ip);
    var response = jsonDecode(responseUpload.toString());
    if (response['status'] != 200) {
      setState(() {
        isLoading = false;
      });

      setState(() {
        messageError = response['error'];
        _showDialog();
      });
    } else {
      setState(() {
        isLoading = false;
      });

      _callWaitAnalysis();
    }    
  }

  _callWaitAnalysis()
  {
    Navigator.pushReplacementNamed(context, '/WaitAnalysis');
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
        title: Text("Adicionar detalhes", style: TextStyle(color: MyColors.grey)),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.send, size: 40, color: MyColors.grey), 
            onPressed: () {
              _uploadVideo(_callWaitAnalysis);
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
