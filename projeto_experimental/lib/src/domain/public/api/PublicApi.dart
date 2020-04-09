import 'dart:convert';

import '../../../HttpConfig.dart';

class PublicApi extends HttpConfig {
  login(controllerEmail, controllerPassword) => 
    this.http.post("/testes/smartemotion/app/api/users/auth.php", data: {
      "token": "token",
      "email": controllerEmail.text,
      "senha": controllerPassword.text
    });
  register(controllerName, controllerEmail, controllerPassword, controllerBirthday, controllerPhone, controllerCountry, controllerIdentity) =>
    this.http.post("/testes/smartemotion/app/api/public/register.php", data: {
      "token": "token",
      "nome": controllerName.text,
      "email": controllerEmail.text,
      "senha": controllerPassword.text,
      "data_aniversario": controllerBirthday.text,
      "telefone": controllerPhone.text,
      "pais": controllerCountry.text,
      "identidade": controllerIdentity.text
    });
}