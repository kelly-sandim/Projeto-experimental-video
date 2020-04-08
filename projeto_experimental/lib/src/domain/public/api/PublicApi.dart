import 'dart:convert';

import '../../../HttpConfig.dart';

class PublicApi extends HttpConfig {
  login(userEmail, userPassword) => 
    this.http.post("/testes/smartemotion/app/api/users/auth.php", data: {
      "token": "token",
      "email": userEmail.toString(),
      "senha": userPassword.toString()
    });
}