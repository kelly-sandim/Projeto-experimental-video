import 'package:flutter/material.dart';

import '../views/Login.dart';

class PublicRouter {
  BuildContext context;

  static var routes = {'/LoginPage': (context) => new Login()};
}
