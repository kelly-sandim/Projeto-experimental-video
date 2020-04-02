import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpConfig {
  bool instance = false;
  Dio http;

  HttpConfig() {
    if (!this.instance) {
      BaseOptions options = new BaseOptions(
        baseUrl: DotEnv().env['URL_API'],
        connectTimeout: 5000,
        receiveTimeout: 3000,
      );

      this.http = new Dio(options);
      this.instance = true;
    }
  }
}
