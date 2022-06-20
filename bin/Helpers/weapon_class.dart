import 'dart:convert';

class Weapon {
  final String name;
  final String description;
  final int radius;

  Weapon({required this.name, required this.description, required this.radius});

  String toJson() {
    return jsonEncode(
        {'name': name, 'description': description, 'radius': radius});
  }
}
