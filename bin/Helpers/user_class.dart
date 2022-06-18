class User {
  final int telegramId;
  final String name;
  String? status;
  Map<String, double>? location;

  User({required this.telegramId, required this.name, this.status});
}
