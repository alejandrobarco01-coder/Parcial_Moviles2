// user_model.dart
// Modelo de usuario retornado por la API de VisionTic Parking
// API: https://parking.visiontic.com.co/api/login

class UserModel {
  final String name;
  final String email;

  const UserModel({
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
      };
}
