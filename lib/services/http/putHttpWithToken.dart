import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> putHttpWithToken(url, token, body) async {
  var res = await http.put(url, body: json.encode(body), headers: {
    HttpHeaders.authorizationHeader: token,
    "content-type": "application/json"
  });
  return res.body;
}
