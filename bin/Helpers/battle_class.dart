import 'dart:convert';

import 'user_class.dart';

class Battle {
  final List<User> participants;

  Battle({required this.participants}) {
    for (var user in participants) {
      user.battle = this;
    }

  }

  Map<String, dynamic> toJson() => {
        'participants': participants.map((user) => user.toJson()).toList(),
      };
  
  Battle.fromJson(Map<String, dynamic> json):
      participants = json['participants'].map((user) => User.fromJson(user)).toList();
}


