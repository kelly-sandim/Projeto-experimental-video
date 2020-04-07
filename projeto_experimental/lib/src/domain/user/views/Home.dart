import 'dart:ui';
import 'dart:io' as Io;
import 'dart:async';
import 'dart:convert';

import 'package:video_player/video_player.dart';
import '../../../../src/assets/colors/MyColors.dart';
import '../api/UserApi.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  TabController tabController;
  List<VideoPlayerController> controllerVideoList =
      new List<VideoPlayerController>();
  List<String> titleVideoList = 
      new List<String>();
  String messageError;
  bool isLoading = true;

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
                      itemCount: controllerVideoList == null
                          ? 0
                          : controllerVideoList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: Column(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  new ListTile(
                                    leading: Icon(Icons.play_circle_filled,
                                        color: MyColors.grey, size: 30),
                                    title: Text(titleVideoList[index],
                                        style: TextStyle(
                                            color: MyColors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20)),
                                    onTap: () {
                                      Navigator.pushNamed(context, '/Result');
                                    },
                                  ),
                                  AspectRatio(
                                  aspectRatio: controllerVideoList[index].value.aspectRatio, 
                                  child: Stack(
                                      alignment: FractionalOffset
                                              .bottomRight +
                                          const FractionalOffset(-0.1, -0.1),
                                      children: <Widget>[
                                        VideoPlayer(
                                            controllerVideoList[index]),
                                        _PlayPauseOverlay(controller: controllerVideoList[index]),
                                        VideoProgressIndicator(controllerVideoList[index], allowScrubbing: true),
                                      ]
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
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/LoginPage');
                },
              ),
              new Divider(),
            ],
          )),
    ];

    return _tabList;
  }

  _loadVideoList() async {
    var userId = "1";
    var responseGet = await new UserApi().getVideos(userId);
    var response = jsonDecode(responseGet.toString());

    print(response);

    if (response['status'] != 200) {
      setState(() {
        messageError = response['error'];
        _showDialog();
      });
    } else {
      for (var item in response["videos"]) {
        controllerVideoList.add(new VideoPlayerController.network(item));
        var urlSplitted = item.split("/");
        titleVideoList.add(urlSplitted[urlSplitted.length-1]);
      }

      for (var item in controllerVideoList) {
        item.addListener(() {
          setState(() {});
        });
        item.setLooping(false);
        item.initialize().then((_) => setState(() {}));
        //item.play();
      }

      setState(() {
        isLoading = false;
      });
    }
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
    tabController = TabController(vsync: this, length: 2);
    _loadVideoList();
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
