import 'dart:convert';

import '../../../HttpConfig.dart';

class UserApi extends HttpConfig {
  getVideos(userId, videoName, base64Video) =>
    this.http.post("/testes/smartemotion/app/api/getVideos.php", data: {
      "token": "token",      
    });
}