import 'dart:convert';

import '../../../HttpConfig.dart';

class UserApi extends HttpConfig {
  getVideos(userId) =>
    this.http.post("/testes/smartemotion/app/api/getVideos.php", data: {
      "token": "token",
      "id_usuario": userId.toString()      
    });
}