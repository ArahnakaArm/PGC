import 'package:http/http.dart' as http;

Future<String> postHttp(url, body) async {
  var res = await http.post(url, body: body);
  return res.body;
}
