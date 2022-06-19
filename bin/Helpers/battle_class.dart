import 'user_class.dart';

class Battle {
  final List<User> participants;

  Battle({required this.participants}) {
    for (var user in participants) {
      user.battle = this;
    }

  }
}


