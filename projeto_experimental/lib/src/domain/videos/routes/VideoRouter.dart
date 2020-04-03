import 'package:flutter/material.dart';

import '../views/SendVideo.dart';
import '../views/WaitAnalysis.dart';
import '../views/Result.dart';

class VideoRouter {
  BuildContext context;

  static var routes = {  
    '/SendVideo': (context) => new SendVideo(),  
    '/WaitAnalysis': (context) => new WaitAnalysis(),
    '/Result': (context) => new Result(),
  };
}