import 'package:flutter/foundation.dart';
import 'package:local_guru_all/src/features/location/data/model/state_model.dart';
import 'package:local_guru_all/src/features/location/data/model/district_model.dart';
import 'package:local_guru_all/src/features/location/data/model/landmark_model.dart';
import 'package:local_guru_all/src/features/location/data/repository/location_repository.dart';

class LocationProvider extends ChangeNotifier {
  final LocationRepository _repository;

  LocationProvider({LocationRepository? repository})
      : _repository = repository ?? LocationRepository();

  // State
  bool _isLoading = false;
  String? _error;

  // Data
  List<StateModel> _states = [];
  List<DistrictModel> _districts = [];
  List<LandmarkModel> _landmarks = [];

  // Selected values
  String? _selectedStateId;
  String? _selectedDistrictId;
  String? _selectedLandmarkId;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<StateModel> get states => _states;
  List<DistrictModel> get districts => _districts;
  List<LandmarkModel> get landmarks => _landmarks;
  String? get selectedStateId => _selectedStateId;
  String? get selectedDistrictId => _selectedDistrictId;
  String? get selectedLandmarkId => _selectedLandmarkId;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Load all states on initialization
  Future<void> loadStates() async {
    _setLoading(true);
    _setError(null);
    try {
      _states = await _repository.getStates();
      _error = null;
    } catch (e) {
      _setError(e.toString());
      _states = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Load districts for selected state
  Future<void> loadDistricts(String stateId) async {
    if (_selectedStateId == stateId && _districts.isNotEmpty) {
      return; // Already loaded
    }

    _selectedStateId = stateId;
    _selectedDistrictId = null;
    _selectedLandmarkId = null;
    _districts = [];
    _landmarks = [];
    notifyListeners();

    _setLoading(true);
    _setError(null);
    try {
      _districts = await _repository.getDistricts(stateId: stateId);
      _error = null;
    } catch (e) {
      _setError(e.toString());
      _districts = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Load landmarks for selected district
  Future<void> loadLandmarks(String stateId, String districtId) async {
    if (_selectedDistrictId == districtId && _landmarks.isNotEmpty) {
      return; // Already loaded
    }

    _selectedDistrictId = districtId;
    _selectedLandmarkId = null;
    _landmarks = [];
    notifyListeners();

    _setLoading(true);
    _setError(null);
    try {
      _landmarks = await _repository.getLandmarks(
        stateId: stateId,
        districtId: districtId,
      );
      _error = null;
    } catch (e) {
      _setError(e.toString());
      _landmarks = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Select state and load districts
  Future<void> selectState(String? stateId) async {
    if (stateId == null || stateId.isEmpty) {
      _selectedStateId = null;
      _selectedDistrictId = null;
      _selectedLandmarkId = null;
      _districts = [];
      _landmarks = [];
      notifyListeners();
      return;
    }

    await loadDistricts(stateId);
  }

  /// Select district and load landmarks
  Future<void> selectDistrict(String stateId, String? districtId) async {
    if (districtId == null || districtId.isEmpty) {
      _selectedDistrictId = null;
      _selectedLandmarkId = null;
      _landmarks = [];
      notifyListeners();
      return;
    }

    await loadLandmarks(stateId, districtId);
  }

  /// Select landmark
  void selectLandmark(String? landmarkId) {
    _selectedLandmarkId = landmarkId;
    notifyListeners();
  }

  /// Clear all selections
  void clearSelection() {
    _selectedStateId = null;
    _selectedDistrictId = null;
    _selectedLandmarkId = null;
    _districts = [];
    _landmarks = [];
    notifyListeners();
  }

  /// Clear error
  void clearError() => _setError(null);
}

