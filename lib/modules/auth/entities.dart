class Token {
  int id = 1;
  String token = '';

  Token();
  Token.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        token = json["token"];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
    };
  }
}

class LoginCredentials {
  String email = '';
  String password = '';
  Map<String, dynamic> toMap() {
    return {
      'username': email.trim(),
      'password': password.trim(),
    };
  }
}
