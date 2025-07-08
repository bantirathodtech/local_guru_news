class LocationModel {
  String? id;
  String? name;
  String? english;
  List<District>? districts;
  LocationModel({
    this.id,
    this.name,
    this.english,
    this.districts,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        id: json["id"],
        name: json["name"],
        english: json["english"],
        districts: List<District>.from(
            json["districts"].map((x) => District.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "english": english,
        "districts": List<dynamic>.from(districts!.map((x) => x.toJson())),
      };
}

class District {
  String? id;
  String? name;
  String? english;
  List<Landmark>? landmarks;
  District({
    this.id,
    this.name,
    this.english,
    this.landmarks,
  });

  factory District.fromJson(Map<String, dynamic> json) => District(
        id: json["id"],
        name: json["name"],
        english: json['english'],
        landmarks: List<Landmark>.from(
            json["landmarks"].map((x) => Landmark.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "english": english,
        "landmarks": List<dynamic>.from(landmarks!.map((x) => x.toJson())),
      };
}

class Landmark {
  String? id;
  String? name;
  String? english;

  Landmark({
    this.id,
    this.name,
    this.english,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) => Landmark(
        id: json["id"],
        name: json["name"],
        english: json["english"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "english": english,
      };
}
