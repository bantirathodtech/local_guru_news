class UserModel {
  String? id;
  String? token;
  String? name;
  String? profile;
  String? contact;

  UserModel({
    this.id,
    this.token,
    this.name,
    this.profile,
    this.contact,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        token: json['token'],
        name: json['name'],
        profile: json['profile'],
        contact: json['contact'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        'token': token,
        "name": name,
        "profile": profile,
        'contact': contact,
      };
}
