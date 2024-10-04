class User {
  String? id;
  String password;
  String image;
  String name;
  String email;

  User({
    this.id,
    required this.password,
    required this.image,
    required this.name,
    required this.email,
  });
}