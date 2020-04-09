import 'package:flutter/material.dart';

import '../views/Login.dart';
import '../views/Register.dart';

class PublicRouter {
  BuildContext context;

  static var routes = {
    '/LoginPage': (context) => new Login(),
    '/Register': (context) => new Register()
  };  
}
