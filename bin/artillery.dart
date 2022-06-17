import 'dart:io';

import 'helpers.dart';

void main(List<String> arguments) {
  print('[${DateTime.now()}]Artillery game bot starts!...');
  File tknFile = File('tkn.txt');
  String tkn = tknFile.readAsStringSync();
  print('token is $tkn');

  Telega telega = Telega(tkn: tkn);
  
  
}
