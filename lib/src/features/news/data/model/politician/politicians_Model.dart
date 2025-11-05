class PoliticianModel {
  String? id;
  String? name;
  String? profile;
  String? type;
  String? status;

  PoliticianModel({
    this.id,
    this.name,
    this.profile,
    this.type,
    this.status,
  });

  factory PoliticianModel.fromJson(Map<String, dynamic> json) {
    return PoliticianModel(
      id: json['id'],
      name: json['name'],
      profile: json['icon'],
      type: json['type'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': profile,
        'type': type,
        'status': status,
      };
}
