import 'dart:convert';

import 'battle_class.dart';
import 'weapon_class.dart';

class User {
  final int telegramId;
  final String name;
  String? status;
  Map<String, double>? location;

  Battle? battle;

  List<Weapon>? weapons;

  User({required this.telegramId, required this.name, this.status});

  String weaponsShowList() {
    String result = '';
    weapons!.map((weapon) => result += '${weapon.name} - ${weapon.description} - ${weapon.radius} km\n').toList();
    return result;
  }

  Map<String, dynamic> toJson() => {
        'telegramId': telegramId,
        'name': name,
        'status': status,
        'location': location,
        'battle': battle,
        'weapons': weapons,
      };

  User.fromJson(Map<String, dynamic> json)
    : telegramId = json['telegramId'],
      name = json['name'],
      status = json['status'],
      location = json['location'],
      weapons = json['weapons'].map((weapon) => Weapon.fromJson(weapon)).toList();
}
