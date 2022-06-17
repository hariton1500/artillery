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
    updateId = DateTime.now().millisecondsSinceEpoch;
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

  Future<void> updater() async {
    try {
      log('req = $updateId');
      var res = await http.get(Uri.parse(url! + 'getUpdates?offset=$updateId'));
      //updateId = updateId! - 1;
      String body = res.body;
      if (body != '{"ok":true,"result":[]}') {
        log(res.body);
        if (body.startsWith('{"ok":true,"result":')) {
          var messages = jsonDecode(body)['result'];
          //log(messages.runtimeType);
          if (messages is List) {
            for (var message in messages) {
              updateId = message['update_id'] + 1;
              log(updateId);
            }
          }
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
