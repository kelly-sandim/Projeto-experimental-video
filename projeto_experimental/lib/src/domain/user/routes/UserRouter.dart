import 'package:flutter/material.dart';

import '../views/Home.dart';

class UserRouter {
  BuildContext context;

  static var routes = {
    '/Home': (context) => new Home(),      
  };
}
