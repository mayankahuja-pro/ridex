class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? profileImage;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImage: json['profileImage'],
    );
  }
}
