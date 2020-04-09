import 'dart:convert';

import '../../../HttpConfig.dart';

class UserApi extends HttpConfig {
  fetchLocation(userId, lat, lng) => 
    this.http.post("/testes/smartemotion/app/api/users/fetchLocation.php", data: { 
      "token": "token", 
      "id_usuario": userId, 
      "lat": lat, 
      "lng": lng 
    });
  getIp(userId) => 
    this.http.post("/testes/smartemotion/app/api/users/getIp.php", data: { 
      "token": "token", 
      "id_usuario": userId      
    });
}