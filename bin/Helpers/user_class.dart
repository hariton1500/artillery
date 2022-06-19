import 'battle_class.dart';
import 'weapon_class.dart';

class User {
  final int telegramId;
  final String name;
  String? status;
  Map<String, double>? location;

  Battle? battle;

  List<Weapon> weapons = [Weapon(name: 'CEASER', description: 'French self-propelled 155 mm/52-calibre gun-howitzer', radius: 42)];

  User({required this.telegramId, required this.name, this.status});

  String weaponsShowList() {
    String result = '';
    weapons.map((weapon) => result += '${weapon.name} - ${weapon.description} - ${weapon.radius} km\n').toList();
    return result;
  }
}
