/// Model representing the auth response from the API.
class UserModel {
  final String token;
  final String? email;

  UserModel({required this.token, this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'] as String,
      email: json['email'] as String?,
    );
  }
}
