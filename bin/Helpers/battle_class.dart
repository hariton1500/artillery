import 'user_class.dart';

class Battle {
  List<User> participants = [];
  String status = 'justCreated';

  Battle({required this.participants}) {
    for (var user in participants) {
      user.battle = this;
    }
  }

  static Map<String, dynamic> toJson(Battle battle) => {
        'participants':
            battle.participants.map((user) => user.toJson()).toList(),
        'status': battle.status
      };

  Battle.fromJson(Map<String, dynamic> json) {
    if (json['participants'] is List) {
      for (var participant in json['participants']) {
        participants.add(User.fromJson(participant));
      }
    }
    status = json['status'];
  }
}
