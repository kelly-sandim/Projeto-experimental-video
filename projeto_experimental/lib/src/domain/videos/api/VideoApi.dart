import 'dart:convert';

import '../../../HttpConfig.dart';

class VideoApi extends HttpConfig {
  uploadVideo(userId, videoName, base64Video) =>
    this.http.post("/testes/smartemotion/app/api/uploadVideo.php", data: {
      "token": "token",
      "id_usuario": userId.toString(),
      "nome_video": videoName.toString(),
      "video": base64Video
    });
}