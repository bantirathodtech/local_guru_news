/// District Model - matches get_districts_api.php response
class DistrictModel {
  final String districtId;
  final String district;
  final String districtEnglish;

  DistrictModel({
    required this.districtId,
    required this.district,
    required this.districtEnglish,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) => DistrictModel(
        districtId: json['district_id']?.toString() ?? '',
        district: json['district']?.toString() ?? '',
        districtEnglish: json['district_english']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'district_id': districtId,
        'district': district,
        'district_english': districtEnglish,
      };
}

