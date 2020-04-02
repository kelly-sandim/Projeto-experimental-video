import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './src/domain/public/views/Login.dart';
import './src/domain/user/views/Home.dart';
import './src/RouterConfig.dart';

Future<void> main() async {
  await DotEnv().load('.envProduction');
  WidgetsFlutterBinding.ensureInitialized();  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var driverId = prefs.getString('id_parceiro');
  runApp(MaterialApp(
    //theme: ThemeData(fontFamily: 'Roboto'),
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: [const Locale('pt', 'BR')],
    debugShowCheckedModeBanner: true,
    title: 'Projeto Experimental',
    home: driverId == null ? Login() : new Home(),
    routes: RouterConfig.routes,
  ));
}

String username;