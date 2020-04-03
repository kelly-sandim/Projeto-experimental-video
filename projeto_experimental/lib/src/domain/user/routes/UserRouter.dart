import 'package:flutter/material.dart';

import '../views/Home.dart';
import '../views/SendVideo.dart';
import '../views/WaitAnalysis.dart';

class UserRouter {
  BuildContext context;

  static var routes = {
    '/Home': (context) => new Home(),  
    '/SendVideo': (context) => new SendVideo(),  
    '/WaitAnalysis': (context) => new WaitAnalysis(),
  };
}
