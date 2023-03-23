import 'dart:io';

import 'package:http/http.dart' as http;

Future<String> getHttpWithTokenTimeout(url, token) async {
  var res = await http.get(url, headers: {
    HttpHeaders.authorizationHeader: token,
  }).timeout(Duration(seconds: 10));
  return res.body;
}
