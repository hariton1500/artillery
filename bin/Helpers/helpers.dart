import 'dart:async';
import 'dart:io';

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
}
