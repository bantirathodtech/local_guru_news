class RequirementsModel {
  String? id;
  String? name;
  String? data;
  String? type;

  RequirementsModel({
    this.id,
    this.name,
    this.data,
    this.type,
  });

  factory RequirementsModel.fromJson(Map<String, dynamic> json) {
    return RequirementsModel(
      id: json['id'],
      name: json['name'],
      data: json['data'],
      type: json['type'],
    );
  }
}
