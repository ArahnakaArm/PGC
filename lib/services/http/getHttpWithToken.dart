import 'dart:io';

import 'package:http/http.dart' as http;

Future<String> getHttpWithToken(url, token) async {
  var res = await http.get(url, headers: {
    HttpHeaders.authorizationHeader: token,
  });
  return res.body;
}
