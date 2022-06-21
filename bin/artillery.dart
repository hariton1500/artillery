import 'dart:convert';
import 'dart:io';

import 'Helpers/helpers.dart';

void main(List<String> arguments) {
  log('Artillery game bot starts!...');
  File state = File('state.txt');
  
  if (state.existsSync()) {
    log('state file exists');
    var json = state.readAsStringSync();
    log(jsonDecode(json));
    var gameGlobal = GameGlobal.fromJson(jsonDecode(json));
    gameGlobal.runLongPolling();
    log('state loaded');
  } else {
    log('state file does not exist');
    var gameGlobal = GameGlobal();
    gameGlobal.runLongPolling();
    log('state created');
  }
 
}
