import 'dart:io';

import 'package:http/http.dart' as http;

Future<String> deleteHttpWithToken(url, token) async {
  var res = await http.delete(url, headers: {
    HttpHeaders.authorizationHeader: token,
  });
  return res.body;
}
