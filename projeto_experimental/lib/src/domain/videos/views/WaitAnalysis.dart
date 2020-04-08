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
        automaticallyImplyLeading: false,
        title: Text("Aguarde...", style: TextStyle(color: MyColors.grey)),        
        backgroundColor: MyColors.white,
        elevation: 0.0, //para tirar a sombra
      ),
      body: Center(         
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Image.asset('./lib/src/assets/other/loadingGears.gif',
                      fit: BoxFit.cover,),   
                  width: 180.0,
                  height: 180.0,                  
                ),
                Padding(padding: EdgeInsets.only(top: 30)),                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: 
                        Text(
                          "Seu vídeo será processado e você será notificado(a) quando a análise estiver pronta.",
                          style: TextStyle(fontSize: 22, color: MyColors.grey, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,                     
                        ),
                    ),
                  ],
                ), 
                //TEMPORÁRIO
                Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: 60,
                  margin: const EdgeInsets.only(top: 25.0),
                  child: FlatButton(                    
                    child: Text(
                      'Voltar para Home',
                      style: TextStyle(color: MyColors.white, fontSize: 20.0),
                    ),
                    color: MyColors.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/Home');
                    },
                  ),
                ),
              ],
            ),
          ),      
      ),
    );
  }
}
