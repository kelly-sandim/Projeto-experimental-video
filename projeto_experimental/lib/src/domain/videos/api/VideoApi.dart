import 'dart:convert';

import '../../../HttpConfig.dart';

class VideoApi extends HttpConfig {
  uploadVideo(userId, videoName, base64Video, lat, lng, ip) =>
    this.http.post("/testes/smartemotion/app/api/videos/uploadVideo.php", data: {
      "token": "token",
      "id_usuario": userId.toString(),
      "nome_video": videoName.toString(),
      "video": base64Video,
      "lat": lat.toString(), 
      "lng": lng.toString(),
      "ip_video": ip.toString()
    });
  getVideos(userId) =>
    this.http.post("/testes/smartemotion/app/api/videos/getVideos.php", data: {
      "token": "token",
      "id_usuario": userId.toString()      
    });
  getJSONResult() =>
    this.http.post("/testes/smartemotion/app/api/videos/getJSONResult.php", data: {
      "token": "token"      
    });

  getAllVideoData(userId) =>
    this.http.post("/testes/smartemotion/app/api/videos/getAllVideoData.php", data: {
      "token": "token",
      "id_usuario": userId.toString() 
  });


  fetchLocation(userId, lat, lng) => 
    this.http.post("/testes/smartemotion/app/api/users/fetchLocation.php", data: { 
      "token": "token", 
      "id_usuario": userId, 
      "lat": lat, 
      "lng": lng 
    });
  fetchIp(userId, ip) => 
    this.http.post("/testes/smartemotion/app/api/users/fetchIp.php", data: { 
      "token": "token", 
      "id_usuario": userId,
      "ip_video": ip,      
    });
}