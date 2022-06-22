import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'battle_class.dart';
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

  List<Battle> battles = [];

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

  Map<String, dynamic> toJson() =>
      {'users': users, 'queue': queue, 'battles': battles};

  GameGlobal.fromJson(Map<String, dynamic> json) {
    log('start loading users');
    if (json['users'] is List) {
      for (var user in json['users']) {
        users.add(User.fromJson(user));
      }
    }
    //users = json['users'].map((user) => User.fromJson(user)).toList();
    log('loaded users: ${users.length}');
    log('start loading queue');
    if (json['queue'] is List) {
      for (var user in json['queue']) {
        queue.add(User.fromJson(user));
      }
    }
    //queue = json['queue'].map((user) => User.fromJson(user)).toList();
    log('loaded queue: ${queue.length}');
    log('start loading battles');
    if (json['battles'] is List) {
      for (var battle in json['battles']) {
        battles.add(Battle.fromJson(battle));
      }
    }
    //battles = json['battles'].map((battle) => Battle.fromJson(battle)).toList();
    log('loaded battles: ${battles.length}');
    File tknFile = File('tkn.txt');
    String tkn = tknFile.readAsStringSync();
    log('token is $tkn');

    telega = Telega(tkn: tkn);

    // start working with queue
    runQueueBatch();
    runBattles();
  }
  void save() {
    log('saving state');
    var file = File('state.txt');
    file.createSync();
    file.openWrite(mode: FileMode.write);
    file.writeAsStringSync(jsonEncode(this));
  }

  void runPeriodics() {
    Timer.periodic(
        Duration(milliseconds: pollingTime), ((timer) => telega!.updater()));
  }

  void runLongPolling() {
    telega?.longPolling().listen((event) {
      handle(event);
    });
  }

  void handle(message) {
    log('start handle:');
    try {
      log(message);
      if (message is Map &&
          message.containsKey('message') &&
          !message['message'].containsKey('location') &&
          !message['message'].containsKey('document')) {
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
      if (message is Map &&
          message.containsKey('message') &&
          message['message'].containsKey('document')) {
        log('message is document.');
        if (!isRegisteredUser(message['message']['from']['id'])) {
          users.add(User(
              telegramId: message['message']['from']['id'],
              name: message['message']['from']['first_name'],
              status: 'justRegistered'));
        }
        answer(
            users.firstWhere((element) =>
                element.telegramId == message['message']['from']['id']),
            'itwasdocument');
      }
      if (message is Map && message.containsKey('callback_query')) {
        log('message is callback_query');
        log('from: ${message['callback_query']['from']['id']}');
        log('data: ${message['callback_query']['data']}');
        if (!isRegisteredUser(message['callback_query']['from']['id'])) {
          log('user is not registered');
          log('adding user to users');
          users.add(User(
              telegramId: message['callback_query']['from']['id'],
              name: message['callback_query']['from']['first_name'],
              status: 'justStarted'));
        }
        answer(
            users.firstWhere((element) =>
                element.telegramId == message['callback_query']['from']['id']),
            message['callback_query']['data']);
      }
      if (message is Map &&
          message.containsKey('message') &&
          message['message'].containsKey('location')) {
        log('it is location message:');
        log('from: ${message['message']['from']['id']}');
        if (!isRegisteredUser(message['message']['from']['id'])) {
          users.add(User(
              telegramId: message['message']['from']['id'],
              name: message['message']['from']['first_name'],
              status: 'justRegistered'));
        } else {
          log('user is registered');
        }
        users
            .firstWhere((element) =>
                element.telegramId == message['message']['from']['id'])
            .location = {
          'latitude': message['message']['location']['latitude'] as double,
          'longitude': message['message']['location']['longitude'] as double
        };
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
        telega?.sendMessage(user, data['mainmenu']!,
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
        telega?.sendMessage(user, data['askGeoPosToJoinBattle']!);
        break;
      case 'gotlocationforentertobattle':
        log('looking for battle to join for user: ${user.telegramId}');
        user.status = 'lookingForBattleToJoin';
        telega?.sendMessage(user, data['lookingBattleToEnter']!);
        queue.add(user);
        break;
      case 'leavebattle':
        log('${user.telegramId} leaves battle');
        user.battle?.participants.remove(user);
        user.status = 'justStarted';
        break;
      default:
        log('text not recognized.');
        log('current user status is ${user.status}');
        log('sending to status handler');
        answerToStatus(user, text);
    }
    save();
  }

  bool isRegisteredUser(int id) {
    return users.where((element) => element.telegramId == id).isNotEmpty;
  }

  Future<void> runQueueBatch() async {
    while (true) {
      if (queue.length == 2) {
        log('queue length is 2');
        startBattle(queue);
        await Future.delayed(Duration(milliseconds: 100));
        queue.clear();
      }
      await Future.delayed(Duration(milliseconds: 1000));
    }
  }

  void startBattle(List<User> newBattleUsers) {
    log('starting new battle');
    battles.add(Battle(participants: newBattleUsers));
    for (User user in newBattleUsers) {
      user.status = 'inBattle';
      telega!.sendMessage(user,
          '${data['welcomeToBattle']!}\nYou got a list of weapons:\n${user.weaponsShowList()}');
    }
    save();
  }

  void answerToStatus(User user, String text) {
    switch (user.status!.toLowerCase()) {
      case 'juststarted':
        telega!.sendMessage(
            user, 'command is not recognized.\n${data['mainmenu']}',
            reply: jsonEncode({
              'inline_keyboard': [
                [
                  {'text': 'join to battle', 'callback_data': '/jointobattle'}
                ]
              ]
            }));
        break;
      case 'waitinggeopostojoinbattle':
        telega?.sendMessage(user, 'we expecting your location, warrior!');
        break;
      case 'lookingforbattletojoin':
        telega?.sendMessage(user, data['lookingBattleToEnter']!);
        break;
      default:
    }
  }

  Future<void> runBattles() async {
    while (true) {
      for (var battle in battles) {
        if (battle.participants.length == 1) {
          telega?.sendMessage(battle.participants.first, 'you win!');
          battle.participants.first.status = 'justStarted';
          battles.remove(battle);
          save();
        }
        switch (battle.status.toLowerCase()) {
          case 'justcreated':
            for (User participant in battle.participants) {
              telega?.sendMessage(participant, data['welcomeToBattle']!,
                  reply: jsonEncode({
                    'inline_keyboard': [
                      [
                        {'text': 'make fire', 'callback_data': '/makeFire'},
                        {'text': 'run drone', 'callback_data': '/runDrone'},
                      ],
                      [
                        {
                          'text': 'leave battle',
                          'callback_data': '/leaveBattle'
                        },
                      ]
                    ]
                  }));
              battle.status = 'mainMenu';
            }
            break;
          default:
        }
      }
      await Future.delayed(Duration(milliseconds: 1000));
    }
  }
}
