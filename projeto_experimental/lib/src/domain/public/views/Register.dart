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
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController controllerName = new TextEditingController();
  TextEditingController controllerEmail = new TextEditingController();
  TextEditingController controllerPassword = new TextEditingController();
  TextEditingController controllerBirthday = new TextEditingController();
  TextEditingController controllerPhone = new TextEditingController();
  TextEditingController controllerCountry = new TextEditingController();
  TextEditingController controllerIdentity = new TextEditingController();

  DateFormat formatBirthday;

  String message = '';
  bool _obscureText = true;

  void _showDialog(var tipo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(tipo),
          content: new Text(message),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK", style: TextStyle(color: MyColors.primaryColor)),
              onPressed: () {
                tipo == "Sucesso!" ? Navigator.pushReplacementNamed(context, '/LoginPage') : Navigator.of(context).pop();
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

  Future<dynamic> _registerUser() async {
    try {
      var responseLogin =
          await new PublicApi().register(controllerName, controllerEmail, controllerPassword, controllerBirthday, controllerPhone, controllerCountry, controllerIdentity);
      var response = jsonDecode(responseLogin.toString());

      if (response['status'] != 200) {
        setState(() {
          message = response['error'];
          _showDialog("Erro!");
        });
      } else {               
          message = "Cadastro efetuado com sucesso! Por favor, faça o login agora.";
          _showDialog("Sucesso!");          
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
    formatBirthday = new DateFormat.yMd('pt');
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
        child: SafeArea(child: 
        Center(
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
                Text( 
                  "\nApenas algumas informações e você estará pronto(a) para postar seus vídeos!\n",            
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: MyColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25
                  ),              
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
                    controller: controllerName,
                    decoration: InputDecoration(
                        border: InputBorder.none,                        
                        labelText: 'Nome'),
                  ),
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
                        labelText: 'E-mail'),
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
                    controller: controllerPassword,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      border: InputBorder.none,                      
                      labelText: 'Senha',
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
                  margin: EdgeInsets.only(top: 25.0),
                  width: MediaQuery.of(context).size.width / 1.1,
                  padding:
                      EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: MyColors.white,
                      ),                         
                  child: DateTimeField(
                    controller: controllerBirthday,
                    style: new TextStyle(
                      //color: Colors.red,
                      fontSize: 15.0,
                    ),
                    format: formatBirthday,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Data de Nascimento'),
                    onShowPicker: (context, _dateTime) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: _dateTime ?? DateTime.now(),
                          lastDate: DateTime(2100));
                      }   
                  ),
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
                    keyboardType: TextInputType.phone,
                    controller: controllerPhone,
                    decoration: InputDecoration(
                        border: InputBorder.none,                        
                        labelText: 'Telefone'),
                  ),
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
                    controller: controllerCountry,
                    decoration: InputDecoration(
                        border: InputBorder.none,                        
                        labelText: 'País'),
                  ),
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
                    keyboardType: TextInputType.number,
                    controller: controllerIdentity,
                    decoration: InputDecoration(
                        border: InputBorder.none, 
                        labelText: 'Identificador',                       
                        hintText: 'CPF, RG, etc...'),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: 60,
                  margin: const EdgeInsets.only(top: 25.0),
                  child: FlatButton(                    
                    child: Text(
                      'CADASTRAR',
                      style: TextStyle(color: MyColors.primaryColor, fontSize: 20.0),
                    ),
                    color: MyColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onPressed: () {
                      _registerUser();
                    },
                  ),
                ),
                // ),
                Padding(padding: EdgeInsets.only(top: 60)),                
              ],
              //),
            ),
          ),
        ),
      ),
    ));
  }
}
