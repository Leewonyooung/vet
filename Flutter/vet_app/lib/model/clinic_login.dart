class ClinicLogin {
  String? id;
  String password;

  ClinicLogin({
    this.id,
    required this.password,
  });

  ClinicLogin.fromMap(Map<dynamic, dynamic> res):
    id = res['id'],
    password = res['password'];
}