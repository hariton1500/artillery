import 'battle_class.dart';
import 'helpers.dart';
import 'weapon_class.dart';

class User {
  int? telegramId;
  String? name;
  String? status;
  Map<String, double>? location;

  Battle? battle;

  List<Weapon> weapons = [];

  User({required this.telegramId, required this.name, this.status});

  String weaponsShowList() {
    String result = '';
    weapons.map((weapon) => result += '${weapon.name} - ${weapon.description} - ${weapon.radius} km\n').toList();
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

  User.fromJson(Map<String, dynamic> json) {
      log('start loading user');
      telegramId = json['telegramId'];
      name = json['name'];
      status = json['status'];
      location = json['location'];
      if (json['weapons'] is List) {
        for (var weapon in json['weapons']) {
          weapons.add(Weapon.fromJson(weapon));
        }
      }
      log('loaded weapons: ${weaponsShowList()}');
  }
} 
