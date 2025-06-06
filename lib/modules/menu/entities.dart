class User {
  bool isActive = true;
  String fullName = '';
  String email = '';
  String userAvatar = '';
  String userPhone = '';
  String userPassword = '';
  String userConfirmPassword = '';
  Hierarquia hierarchy = Hierarquia();

  User();
  User.fromJson(Map<String, dynamic> json)
      : userAvatar = json["user_avatar_url"] ?? '', // URL avatar do usuário
        fullName = json["full_name"],
        email = json["email"],
        userPhone = json["user_phone"] ?? '',
        userPassword = json["user_password"] ?? '',
        isActive = json["is_active"],
        hierarchy = Hierarquia.fromJson(json["hierarchy"]);

  User copyWith({
    bool? isActive,
    String? fullName,
    String? email,
    String? userAvatar,
    String? userPhone,
    String? userPassword,
    String? userConfirmPassword,
    Hierarquia? hierarchy,
  }) {
    return User()
      ..isActive = isActive ?? this.isActive
      ..fullName = fullName ?? this.fullName
      ..email = email ?? this.email
      ..userAvatar = userAvatar ?? this.userAvatar
      ..userPhone = userPhone ?? this.userPhone
      ..userPassword = userPassword ?? this.userPassword
      ..userConfirmPassword = userConfirmPassword ?? this.userConfirmPassword
      ..hierarchy = hierarchy ?? this.hierarchy;
  }
}

class Hierarquia {
  bool applicationFeature = true;
  bool ovitrapFeature = false;
  bool placevisitFeature = false;

  Hierarquia();

  Hierarquia.fromJson(Map<String, dynamic> json)
      : applicationFeature = json["application_feature_app"],
        ovitrapFeature = json["ovitrap_feature_app"],
        placevisitFeature = json["placevisit_feature_app"];
}
