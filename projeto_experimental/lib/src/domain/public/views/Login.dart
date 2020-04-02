import 'dart:ui';
import 'dart:async';
import 'dart:convert';

//import 'package:app_vem_rodar_motorista/src/domain/public/api/PublicApi.dart';
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
  _addId(dynamic userId, dynamic userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', userId);
    prefs.setString('userName', userName);
  }

  TextEditingController controllerUser = new TextEditingController();
  TextEditingController controllerPass = new TextEditingController();

  String message = '';
  bool _obscureText = true;
  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Erro!"),
          content: new Text(message),
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

  void showLongToast() {
    Fluttertoast.showToast(
      msg: "Não há conexão com a internet! Por favor tente mais tarde.",
      toastLength: Toast.LENGTH_LONG,
    );
  }

  Future<dynamic> _login() async {
    // try {
    //   var response =
    //       await new PublicApi().login(controllerUser, controllerPass);
    //   response = jsonDecode(response.data.toString());

    //   if (response['code'] == "error") {
    //     setState(() {
    //       message = response['message'];
    //       _showDialog();
    //     });
    //   } else {
    //     var nomeResumido = response['nome'].split(" ");
    //     var driverName = nomeResumido[0] + " " + nomeResumido[1];
    //     _addId(response['id'], driverName);
        Navigator.pushReplacementNamed(context, '/HomeView');
    //   }
    //   return response;
    // } catch (e) {
    //   return showLongToast();
    // }
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
      backgroundColor: Colors.blueAccent,
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
                  padding: EdgeInsets.only(top: 77.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Image(
                      width: 135,
                      height: 135,
                      image: AssetImage('assets/images/vemrodar.png'),
                    ),
                  ),
                  width: 170.0,
                  height: 170.0,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                ),
                Container(
                  margin: EdgeInsets.only(top: 25.0),
                  width: MediaQuery.of(context).size.width / 1.2,
                  padding:
                      EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5)
                      ]),
                  child: TextFormField(
                    controller: controllerUser,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                        hintText: 'Usuário'),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: 50,
                  margin: EdgeInsets.only(top: 32),
                  padding:
                      EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5)
                      ]),
                  child: TextField(
                    controller: controllerPass,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.vpn_key,
                        color: Colors.black,
                      ),
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
                  margin: const EdgeInsets.only(top: 20.0),
                  child: MaterialButton(
                    height: 50.0,
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                    color: Color(0xFF3F51B5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
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
                      "Ao prosseguir com o Login, você concorda com os nossos  ",
                      style: TextStyle(fontSize: 8, color: Colors.white),
                    ),
                    InkWell(
                        child: Text("Termos de Uso",
                            style: TextStyle(
                                fontSize: 8,
                                decoration: TextDecoration.underline,
                                color: Colors.white)),
                        onTap: () => launch(
                            "${DotEnv().env['URL_VEMRODAR']}/app/google_terms.php"))
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
