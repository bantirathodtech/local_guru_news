import 'package:local_guru_all/src/core/api/custom/endpoints/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';
import 'package:local_guru_all/src/core/api/shared/config/api_service_config.dart';
import 'package:local_guru_all/src/features/location/data/model/state_model.dart';
import 'package:local_guru_all/src/features/location/data/model/district_model.dart';
import 'package:local_guru_all/src/features/location/data/model/landmark_model.dart';

class LocationRepository {
  final ApiService _apiService;

  LocationRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService(config: ApiServiceConfig.fromEnvironment());

  /// Get States API - GET request
  Future<List<StateModel>> getStates() async {
    final response = await _apiService.get(
      ApiEndpoints.getStatesApiV1,
      caller: 'LocationRepository.getStates',
    );

    if (response is List) {
      return response
          .map((item) => StateModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Get Districts API - POST request with state_id
  Future<List<DistrictModel>> getDistricts({required String stateId}) async {
    final response = await _apiService.post(
      ApiEndpoints.getDistrictsApiV1,
      {'state_id': stateId},
      caller: 'LocationRepository.getDistricts',
      forceFormData: true,
    );

    if (response is List) {
      return response
          .map((item) => DistrictModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Get Landmarks API - POST request with state_id and district_id
  /// Note: API uses 'state_id' (lowercase) as per user confirmation
  Future<List<LandmarkModel>> getLandmarks({
    required String stateId,
    required String districtId,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.getLandmarksApiV1,
      {
        'state_id': stateId,
        'district_id': districtId,
      },
      caller: 'LocationRepository.getLandmarks',
      forceFormData: true,
    );

    if (response is List) {
      return response
          .map((item) => LandmarkModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}

