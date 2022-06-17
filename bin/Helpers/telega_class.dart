import 'dart:convert';
import 'dart:io';
import 'helpers.dart';
import 'package:http/http.dart' as http;

// class to work with Telegram Bot API

class Telega {
  String? url;
  int? updateId;

  Telega({required String tkn}) {
    url = 'https://api.telegram.org/bot$tkn/';
    updateId = 0;
    log('Telega object created!');

    try {
      var res = http.get(Uri.parse(url! + 'getMe'));
      res.then((value) =>
          log('my name is ${jsonDecode(value.body)['result']['first_name']}'));
    } catch (e) {
      log(e.toString());
      exit(0);
    }
  }
}