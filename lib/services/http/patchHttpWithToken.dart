import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> patchHttpWithToken(url, token, body) async {
  var res = await http.patch(url, body: json.encode(body), headers: {
    HttpHeaders.authorizationHeader: token,
    "content-type": "application/json"
  });
  return res.body;
}
