import 'dart:convert';

import '../../../HttpConfig.dart';

class PublicApi extends HttpConfig {
  login(userName, userPassword) => 
    this.http.post("/testes/smartemotion/app/api/users/auth.php", data: {
      "usuario": userName.toString(),
      "senha": userPassword.toString()
    });
}