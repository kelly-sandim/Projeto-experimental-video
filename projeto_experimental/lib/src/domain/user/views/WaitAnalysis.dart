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

class WaitAnalysis extends StatefulWidget {
  @override
  _WaitAnalysisState createState() => _WaitAnalysisState();
}

class _WaitAnalysisState extends State<WaitAnalysis> {  
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,      
      appBar: AppBar(
        title: Text("Aguarde...", style: TextStyle(color: MyColors.grey)),        
        backgroundColor: MyColors.white,
        elevation: 0.0, //para tirar a sombra
      ),
      body: Center(         
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  //padding: EdgeInsets.only(top: 77.0),
                  child: CircularProgressIndicator(),        
                  width: 125.0,
                  height: 125.0,                  
                ),
                Padding(padding: EdgeInsets.only(top: 25)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: 
                        Text(
                          "Seu vídeo está sendo processado e a análise do vídeo sairá em instantes...",
                          style: TextStyle(fontSize: 22, color: MyColors.grey, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,                     
                        ),
                    ),
                  ],
                ), 
              ],
            ),
          ),      
      ),
    );
  }
}
