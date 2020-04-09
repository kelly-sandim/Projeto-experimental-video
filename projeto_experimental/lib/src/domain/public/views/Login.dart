import 'dart:ui';
import 'dart:async';
import 'dart:convert';

import '../../../../src/assets/colors/MyColors.dart';
import '../api/PublicApi.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController controllerEmail = new TextEditingController();
  TextEditingController controllerPass = new TextEditingController();

  String message = '';
  bool _obscureText = true;

  _addId(dynamic userId, dynamic userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', userId);
    prefs.setString('userEmail', userEmail);
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Erro!"),
          content: new Text(message),
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

  void showLongToast() {
    Fluttertoast.showToast(
      msg: "Não há conexão com a internet! Por favor tente mais tarde.",
      toastLength: Toast.LENGTH_LONG,
    );
  }

  Future<dynamic> _login() async {
    try {
      var responseLogin =
          await new PublicApi().login(controllerEmail, controllerPass);
      var response = jsonDecode(responseLogin.toString());

      if (response['status'] != 200) {
        setState(() {
          message = response['error'];
          _showDialog();
        });
      } else {       
        _addId(response['user_data']['id'], response['user_data']['email']);
        Navigator.pushReplacementNamed(context, '/Home');
      }
      return response;
    } catch (e) {
      return showLongToast();
    }
  }

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
      backgroundColor: MyColors.primaryColor,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  //padding: EdgeInsets.only(top: 77.0),
                  child: Image(                    
                    image: AssetImage('./lib/src/assets/images/youtubeReverse.png'),
                  ),                
                  width: 150.0,
                  height: 150.0,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                ),
                Container(
                  margin: EdgeInsets.only(top: 25.0),
                  width: MediaQuery.of(context).size.width / 1.1,
                  padding:
                      EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: MyColors.white,
                      ),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: controllerEmail,
                    decoration: InputDecoration(
                        border: InputBorder.none,                        
                        hintText: 'E-mail'),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  margin: EdgeInsets.only(top: 20),
                  padding:
                      EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: MyColors.white,
                      ),
                  child: TextField(
                    controller: controllerPass,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      border: InputBorder.none,                      
                      hintText: 'Senha',
                      suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            semanticLabel: _obscureText ? "Show" : "Hide",
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText ^= true;
                            });
                          }),
                    ),
                  ),
                ),

                Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: 60,
                  margin: const EdgeInsets.only(top: 25.0),
                  child: FlatButton(                    
                    child: Text(
                      'LOGIN',
                      style: TextStyle(color: MyColors.primaryColor, fontSize: 20.0),
                    ),
                    color: MyColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onPressed: () {
                      _login();
                    },
                  ),
                ),
                // ),
                Padding(padding: EdgeInsets.only(top: 60)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Não possui um login? Então registre-se ",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    InkWell(
                        child: Text("aqui!",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                color: Colors.white)),
                        onTap: () {
                          Navigator.pushNamed(context, '/Register');
                        }
                    )
                  ],
                ),
              ],
              //),
            ),
          ),
        ),
      ),
    );
  }
}
