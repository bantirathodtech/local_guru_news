class MobileAuth {
  String? mobile;
  int? otp;
  int? id;

  MobileAuth({
    this.mobile,
    this.otp,
    this.id,
  });

  factory MobileAuth.fromJson(Map<String, dynamic> json) {
    return MobileAuth(
      mobile: json['mobile'],
      otp: json['otp'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'mobile': mobile,
        'otp': otp,
        'id': id,
      };
}
