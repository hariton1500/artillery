import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'data.dart';
import 'telega_class.dart';
import 'user_class.dart';

void log(dynamic mess) {
  print('[${DateTime.now()}] $mess');
}

// global service class containing everithing inside
class GameGlobal {
  Telega? telega;
  String? tkn;
  List<User> users = [];
  int pollingTime = 2000; //time to poll Telegramm Bot updates

  DateTime now() {
    return DateTime.now();
  }

  GameGlobal() {
    File tknFile = File('tkn.txt');
    String tkn = tknFile.readAsStringSync();
    log('token is $tkn');

    telega = Telega(tkn: tkn);
  }

  void runPeriodics() {
    Timer.periodic(
        Duration(milliseconds: pollingTime), ((timer) => telega!.updater()));
  }

  void runLongPolling() {
    telega!.longPolling().listen((event) {
      handle(event);
    });
  }

  void handle(message) {
    log('start handle:');
    try {
      if (message is Map && message.containsKey('message')) {
        var decodedMessage = message['message'];
        //log(decodedMessage.toString());

        int messageId = decodedMessage['message_id'];
        int fromId = decodedMessage['from']['id'];
        String fromFirstName = decodedMessage['from']['first_name'];
        int date = decodedMessage['date'];
        String text = decodedMessage['text'];

        log('$fromId: $text');

        if (users.where((element) => element.telegramId == fromId).isEmpty) {
          users.add(User(
              telegramId: fromId, name: fromFirstName, status: 'justStarted'));
          answer(users.last, text);
        } else {
          answer(users.firstWhere((element) => element.telegramId == fromId),
              text);
        }
      } else {
        log('decoding failed:');
        log(message);
        answer(
            users.firstWhere((element) =>
                element.telegramId == message['callback_query']['from']['id']),
            message['callback_query']['data']);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  void answer(User user, String text) {
    switch (text.toLowerCase()) {
      case '/start':
        if (user.status == 'justStarted') {
          telega!.sendMessage(user, data['greetings']!,
              reply: jsonEncode({
                'inline_keyboard': [
                  [
                    {'text': 'register', 'callback_data': '/register'}
                  ]
                ]
              }));
        } else {
          switch (user.status) {
            case 'justRegistered':
              //main menu
              log('sending main menu');
              break;
            case 'qwe':
              break;
            default:
          }
        }
        break;
      case '/register':
        log('wants register');
        break;
      default:
    }
  }
}
