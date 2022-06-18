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
  List<User> queue = [];

  DateTime now() {
    return DateTime.now();
  }

  GameGlobal() {
    File tknFile = File('tkn.txt');
    String tkn = tknFile.readAsStringSync();
    log('token is $tkn');

    telega = Telega(tkn: tkn);

    // start working with queue
    runQueueBatch();
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
      log(message);
      if (message is Map && message.containsKey('message') && !message['message'].containsKey('location')) {
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
      }
      if (message is Map && message.containsKey('callback_query')) {
        log('decoding failed:');
        log('from: ${message['callback_query']['from']['id']}');
        if (!isRegisteredUser(message['callback_query']['from']['id'])) {
          users.add(User(
              telegramId: message['callback_query']['from']['id'],
              name: message['callback_query']['from']['first_name'],
              status: 'justStarted'));
        }
        answer(
            users.firstWhere((element) =>
                element.telegramId == message['callback_query']['from']['id']),
            data['rigistered']!);
      }
      if (message is Map && message.containsKey('message') && message['message'].containsKey('location')) {
        log('it is location message:');
        log('from: ${message['message']['from']['id']}');
        if (!isRegisteredUser(message['message']['from']['id'])) {
          users.add(User(
              telegramId: message['message']['from']['id'],
              name: message['message']['from']['first_name'],
              status: 'justRegistered'));
        }
        users.firstWhere((element) =>
                element.telegramId == message['message']['from']['id'])
            .location = message['message']['location'];
        answer(
            users.firstWhere((element) =>
                element.telegramId == message['message']['from']['id']),
            'gotLocationForEnterToBattle');
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
        user.status = 'justRegistered';
        telega!.sendMessage(user, data['mainmenu']!,
              reply: jsonEncode({
                'inline_keyboard': [
                  [
                    {'text': 'join to battle', 'callback_data': '/jointobattle'}
                  ]
                ]
              }));
        break;
      case '/jointobattle':
        log('wants join to battle');
        user.status = 'waitingGeoPosToJoinBattle';
        telega!.sendMessage(user, data['askGeoPosToJoinBattle']!);
        break;
      case 'gotLocationForEnterToBattle':
        log('looking for battle to join for user: ${user.telegramId}');
        user.status = 'lookingForBattleToJoin';
        telega!.sendMessage(user, data['lookingBattleToEnter']!);
        queue.add(user);
        break;
      default:
    }
  }

  bool isRegisteredUser(int id) {
    return users.where((element) => element.telegramId == id).isNotEmpty;
  }

  void runQueueBatch() async {
    while (true) {
      if (queue.length == 2) {
        log('queue length is 2');
        startBattle(queue);
        queue.clear();
      }
      await Future.delayed(Duration(milliseconds: 1000));
  }
}

  void startBattle(List<User> newBattleUsers) {}
}
