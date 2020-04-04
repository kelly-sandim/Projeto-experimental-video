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

class SendVideo extends StatefulWidget {
  @override
  _SendVideoState createState() => _SendVideoState();
}

class _SendVideoState extends State<SendVideo> {  
  TextEditingController controllerTitle = new TextEditingController();
  TextEditingController controllerDescription = new TextEditingController();
  
  String videoPath;

  _getData() async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      controllerTitle.text = prefs.getString('videoName');
      videoPath = prefs.getString('videoPath');     
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _getData();
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
                  //padding: EdgeInsets.only(top: 77.0),
                  child: Image(                    
                    image: AssetImage('./lib/src/assets/images/youtube.png'),
                  ),                
                  width: 250.0,
                  height: 250.0,
                  decoration: BoxDecoration(shape: BoxShape.circle),
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
