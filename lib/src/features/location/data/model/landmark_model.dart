/// Landmark Model - matches get_landmars_api.php response
class LandmarkModel {
  final String landmarkId;
  final String districtId;
  final String stateId;
  final String landmark;
  final String landmarkEnglish;

  LandmarkModel({
    required this.landmarkId,
    required this.districtId,
    required this.stateId,
    required this.landmark,
    required this.landmarkEnglish,
  });

  factory LandmarkModel.fromJson(Map<String, dynamic> json) => LandmarkModel(
        landmarkId: json['landmark_id']?.toString() ?? '',
        districtId: json['district_id']?.toString() ?? '',
        stateId: json['state_id']?.toString() ?? '',
        landmark: json['landmark']?.toString() ?? '',
        landmarkEnglish: json['landmark_english']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'landmark_id': landmarkId,
        'district_id': districtId,
        'state_id': stateId,
        'landmark': landmark,
        'landmark_english': landmarkEnglish,
      };
}

