import 'dart:convert';

import '../../../HttpConfig.dart';

class PublicApi extends HttpConfig {
  login(controllerEmail, controllerPassword) => 
    this.http.post("/testes/smartemotion/app/api/users/auth.php", data: {
      "token": "token",
      "email": controllerEmail.text,
      "senha": controllerPassword.text
    });
}