class UserModel {
  String? id;
  String? token;
  String? name;
  String? profile;
  String? contact;
  String? role;
  String? email;
  String? aadharNumber;
  String? address;

  UserModel({
    this.id,
    this.token,
    this.name,
    this.profile,
    this.contact,
    this.role,
    this.email,
    this.aadharNumber,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString(),
        token: json['token']?.toString(),
        name: json['name']?.toString(),
        profile: json['profile']?.toString(),
        contact: json['contact']?.toString(),
        role: json['role']?.toString(),
        email: json['email']?.toString(),
        aadharNumber: json['aadhar_number']?.toString() ?? json['aadharNumber']?.toString(),
        address: json['address']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        'token': token,
        "name": name,
        "profile": profile,
        'contact': contact,
        'role': role,
        'email': email,
        'aadhar_number': aadharNumber,
        'address': address,
      };
}
