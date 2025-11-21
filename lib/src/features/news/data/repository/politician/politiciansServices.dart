import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';
import 'package:local_guru_all/src/features/news/data/model/politician/politicians_Model.dart';

final politicansServiceProvider = Provider<PoliticiansService>((ref) {
  return PoliticiansService();
});

class PoliticiansService {
  PoliticiansService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  /// Fetch politicians using new list API, with optional search + pagination.
  /// Falls back to legacy topics API when new API fails and search is empty.
  Future<List<PoliticianModel>> getTopics({
    int page = 1,
    int status = 1,
    String search = '',
  }) async {
    final trimmedSearch = search.trim();
    try {
      developer.log(
        'PoliticiansService: Fetching politicians (page=$page, status=$status, search="$trimmedSearch")',
      );
      final payload = <String, dynamic>{
        'page': page.toString(),
      };
      if (status >= 0) {
        payload['status'] = status.toString();
      }
      if (trimmedSearch.isNotEmpty) {
        payload['search'] = trimmedSearch;
      }

      final response = await _apiService.post(
        ApiEndpoints.listPoliticiansApi,
        payload,
        forceFormData: true,
        caller: 'PoliticiansService.listPoliticians',
      );

      _logSampleResponse('List Politicians API', response);
      final politicians = _mapPoliticiansFromPoliticiansApi(response);
      developer.log(
        'PoliticiansService: List API returned ${politicians.length} politicians',
      );

      if (politicians.isNotEmpty || trimmedSearch.isNotEmpty) {
        return politicians;
      }
      developer.log(
        'PoliticiansService: List API empty, attempting legacy fallback...',
      );
    } catch (e, stackTrace) {
      developer.log(
        'PoliticiansService: List API failed: $e',
        error: e,
        stackTrace: stackTrace,
      );
      if (trimmedSearch.isNotEmpty) {
        return const [];
      }
    }

    return _fetchPoliticiansFromLegacyTopics();
  }

  Future<List<PoliticianModel>> _fetchPoliticiansFromLegacyTopics() async {
    try {
      developer.log(
        'PoliticiansService: Fetching politicians from topics API (fallback)',
      );
      final response = await _apiService.post(
        ApiEndpoints.topicsApi,
        const <String, dynamic>{},
        forceFormData: true,
        caller: 'PoliticiansService.getTopicsFallback',
      );

      developer.log(
        'PoliticiansService: Topics API response type: ${response.runtimeType}',
      );
      _logSampleResponse('Topics API fallback', response);

      final politicians = _mapPoliticiansFromTopics(response);
      developer.log(
        'PoliticiansService: Topics API mapped ${politicians.length} politicians',
      );

      if (politicians.isEmpty) {
        developer.log(
          'PoliticiansService: WARNING - No politicians found in topics API response',
        );
      }

      return politicians;
    } catch (e, stackTrace) {
      developer.log(
        'PoliticiansService: Topics API fallback failed: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  /// Maps dedicated politician API response to PoliticianModel list
  List<PoliticianModel> _mapPoliticiansFromPoliticiansApi(dynamic response) {
    try {
      final items = _normalizeResponseToList(response);
      if (items.isEmpty) {
        developer.log('PoliticiansService: Dedicated API response empty');
        return const [];
      }

      final List<PoliticianModel> politicians = [];
      for (final item in items) {
        if (item is! Map) continue;

        final id =
            _firstNonEmpty(item, const ['id', 'politician_id', 'politicianId'])
                ?.toString();
        final name = _firstNonEmpty(
                item, const ['name', 'politician_name', 'politicianName'])
            ?.toString();
        final rawIcon = _firstNonEmpty(
          item,
          const ['icon', 'profile', 'profile_image', 'profileImage', 'image'],
        )?.toString();
        final icon = _sanitizeImageUrl(rawIcon);
        final status = _firstNonEmpty(
                    item, const ['status', 'follow_status', 'followStatus'])
                ?.toString() ??
            '0';
        final type =
            _firstNonEmpty(item, const ['type', 'category'])?.toString() ??
                'politician';

        if (id == null || name == null) {
          developer.log(
              'PoliticiansService: Skipping entry missing id or name: $item');
          continue;
        }

        politicians.add(
          PoliticianModel(
            id: id,
            name: name,
            profile: icon,
            type: type,
            status: status,
          ),
        );
      }

      return politicians;
    } catch (e, stackTrace) {
      developer.log(
        'PoliticiansService: Error mapping dedicated API response: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  /// Maps topics API response to PoliticianModel list
  /// Filters items where type == 'politician'
  List<PoliticianModel> _mapPoliticiansFromTopics(dynamic response) {
    try {
      List<dynamic> topicsList = [];

      // Handle different response formats
      if (response is String) {
        final decoded = jsonDecode(response);
        topicsList = _extractTopicsList(decoded);
      } else if (response is List) {
        topicsList = response;
        developer.log(
            'PoliticiansService: Response is a List with ${topicsList.length} items');
      } else if (response is Map<String, dynamic>) {
        topicsList = _extractTopicsList(response);
        developer.log(
            'PoliticiansService: Response is a Map, extracted ${topicsList.length} items');
      } else {
        developer.log(
            'PoliticiansService: Unknown response type: ${response.runtimeType}');
        return const [];
      }

      developer
          .log('PoliticiansService: Total topics found: ${topicsList.length}');

      // Filter for politicians and map to PoliticianModel
      // Use similar approach to TopicsRepository to handle Map<dynamic, dynamic>
      final List<PoliticianModel> politicians = [];
      final List<String> foundTypes = [];

      for (final item in topicsList) {
        if (item == null) continue;

        // Handle Map type (could be Map<dynamic, dynamic> or Map<String, dynamic>)
        if (item is Map) {
          try {
            // Log all types found for debugging
            final typeValue = item['type'];
            final type = typeValue?.toString().toLowerCase();
            if (type != null && !foundTypes.contains(type)) {
              foundTypes.add(type);
            }

            // Check if type is 'politician' (case-insensitive)
            if (type == 'politician') {
              // Extract values safely
              final id = item['id']?.toString();
              final name = item['name']?.toString();
              final icon = _sanitizeImageUrl(
                  item['profile']?.toString() ?? item['icon']?.toString());
              final status = item['status']?.toString() ?? '0';

              if (id != null && name != null) {
                developer.log(
                    'PoliticiansService: Found politician: $name (id: $id, type: $type)');

                politicians.add(
                  PoliticianModel(
                    id: id,
                    name: name,
                    profile: icon, // icon maps to profile
                    type: typeValue?.toString(), // Keep original case
                    status: status,
                  ),
                );
              } else {
                developer.log(
                    'PoliticiansService: Skipping politician with missing id or name: $item');
              }
            }
          } catch (e) {
            developer.log(
                'PoliticiansService: Error processing item: $e, item: $item');
          }
        }
      }

      // Log all types found for debugging
      if (foundTypes.isNotEmpty) {
        developer.log(
            'PoliticiansService: Found topic types in response: ${foundTypes.join(", ")}');
      } else {
        developer
            .log('PoliticiansService: WARNING - No types found in any items');
      }

      developer
          .log('PoliticiansService: Mapped ${politicians.length} politicians');
      return politicians;
    } catch (e, stackTrace) {
      developer.log(
        'PoliticiansService: Error mapping politicians: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  /// Extracts topics list from various response formats
  List<dynamic> _extractTopicsList(dynamic response) {
    if (response is List) {
      return response;
    }
    if (response is Map) {
      // Try common keys
      if (response['result'] is List) {
        return response['result'] as List;
      }
      if (response['data'] is List) {
        return response['data'] as List;
      }
      if (response['topics'] is List) {
        return response['topics'] as List;
      }
    }
    return [];
  }

  List<dynamic> _normalizeResponseToList(dynamic response) {
    if (response is List) return response;
    if (response is String) {
      try {
        final decoded = jsonDecode(response);
        return _normalizeResponseToList(decoded);
      } catch (_) {
        return [];
      }
    }
    if (response is Map) {
      for (final key in const ['politicians', 'data', 'result', 'items']) {
        final value = response[key];
        if (value is List) return value;
      }
      return [];
    }
    return [];
  }

  dynamic _firstNonEmpty(Map<dynamic, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (!map.containsKey(key)) continue;
      final value = map[key];
      if (value == null) continue;
      final stringValue = value.toString().trim();
      if (stringValue.isEmpty || stringValue.toLowerCase() == 'null') continue;
      return value;
    }
    return null;
  }

  void _logSampleResponse(String source, dynamic response) {
    try {
      final list = _normalizeResponseToList(response);
      if (list.isNotEmpty) {
        final first = list.first;
        if (first is Map || first is List) {
          developer.log('$source sample item: ${jsonEncode(first)}');
        } else {
          developer.log('$source sample item: $first');
        }
        return;
      }

      if (response is Map) {
        developer.log('$source sample map: ${jsonEncode(response)}');
      } else {
        developer.log('$source raw response: $response');
      }
    } catch (e) {
      developer.log('$source sample logging failed: $e');
    }
  }

  String? _sanitizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final trimmed = url.trim();
    if (trimmed.startsWith('http')) return trimmed;

    final cleaned = trimmed.replaceFirst(RegExp(r'^(\.\./)+'), '');
    final normalized = cleaned.startsWith('/') ? cleaned.substring(1) : cleaned;
    return 'https://localguru.in/$normalized';
  }
}
