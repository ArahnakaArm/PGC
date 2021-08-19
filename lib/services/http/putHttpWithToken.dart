import 'dart:io';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> postHttpWithToken(url, token, body) async {
  var res = await http.put(url, body: body, headers: {
    HttpHeaders.authorizationHeader: token,
  });
  return res.body;
}
