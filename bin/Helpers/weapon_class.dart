class Weapon {
  final String name;
  final String description;
  final int radius;

  Weapon({required this.name, required this.description, required this.radius});

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'radius': radius,
      };
  
  Weapon.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      description = json['description'],
      radius = json['radius'];
}
