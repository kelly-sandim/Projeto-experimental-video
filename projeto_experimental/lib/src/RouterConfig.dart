import 'package:flutter/material.dart';

import 'domain/user/routes/UserRouter.dart';
import 'domain/public/routes/PublicRouter.dart';
import 'domain/videos/routes/VideoRouter.dart';

class RouterConfig {
  BuildContext context;

  static var routes = {
    ...PublicRouter.routes,
    ...UserRouter.routes,
    ...VideoRouter.routes,    
  };
}