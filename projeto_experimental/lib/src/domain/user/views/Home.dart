import 'dart:ui';
import 'dart:async';
import 'dart:convert';

import '../../../../src/assets/colors/MyColors.dart';
//import 'package:app_vem_rodar_motorista/src/domain/public/api/PublicApi.dart';
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

   List<Widget> tabList = [
    Container(
      color: MyColors.white
    ),
    Container(
      color: MyColors.white,
    ),
  ];

  TabController tabController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    tabController = TabController(vsync: this, length: tabList.length);
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
          IconButton(icon: Icon(Icons.videocam, size: 40, color: MyColors.grey), 
            onPressed: () {              
              Navigator.pushNamed(context, '/RecordVideo');
            }),          
        ],
        backgroundColor: MyColors.white,
        elevation: 0.0, //para tirar a sombra
      ),
      body: TabBarView(
        controller: tabController,
        children: tabList,
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
            title: Text("Meus vídeos", style: TextStyle(color: currentIndex == 0 ? MyColors.primaryColor : MyColors.grey, fontSize: 18)),
            icon: Icon(Icons.video_library, color: MyColors.grey),
            activeIcon: Icon(Icons.video_library, color: MyColors.primaryColor),
          ),
          BottomNavigationBarItem(
            title: Text("Configurações", style: TextStyle(color: currentIndex == 1 ? MyColors.primaryColor : MyColors.grey, fontSize: 18)),
            icon: Icon(Icons.settings, color: MyColors.grey),
            activeIcon: Icon(Icons.video_library, color: MyColors.primaryColor),
          )
        ],
      ),
    );
  }
}
