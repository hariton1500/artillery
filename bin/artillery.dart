import 'Helpers/helpers.dart';

void main(List<String> arguments) {
  log('Artillery game bot starts!...');
  GameGlobal gameGlobal = GameGlobal();

  //gameGlobal.runPeriodics();
  gameGlobal.runLongPolling();
}
