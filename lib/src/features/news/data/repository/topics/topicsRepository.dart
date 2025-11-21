import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';
import 'package:local_guru_all/src/features/news/data/model/topics/topics_Model.dart';

final topicsRepositoryProvider = Provider<TopicsRepository>((ref) {
  return TopicsRepository();
});

class TopicsRepository {
  TopicsRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<TopicsModel>> getTopics() async {
    try {
      // Pass empty Map<String, dynamic> to avoid type casting issues
      final response = await _apiService.post(
        ApiEndpoints.topicsApi,
        <String, dynamic>{},
        forceFormData: true,
        caller: 'TopicsRepository.getTopics',
      );

      // The API returns a direct JSON array: [{"id":"1","name":"...","icon":"...","tags":"..."}, ...]
      // ApiLoggingHelper already decodes JSON, so response should be a List
      // But we need to handle type conversion from List<dynamic> with Map<dynamic, dynamic> items

      return _parseTopicsResponse(response);
    } catch (e, stackTrace) {
      // Log error for debugging
      print('Error in TopicsRepository.getTopics: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Parses the topics API response and converts to TopicsModel list
  List<TopicsModel> _parseTopicsResponse(dynamic response) {
    try {
      // Handle String response (if somehow not decoded)
      if (response is String) {
        final decoded = jsonDecode(response);
        return _parseTopicsResponse(decoded);
      }

      // Handle direct List response (API returns array directly)
      if (response is List) {
        final List<TopicsModel> topics = [];
        for (final item in response) {
          final topic = _mapTopicItem(item);
          if (topic != null) {
            topics.add(topic);
          }
        }
        return topics;
      }

      // Handle Map response with 'result' key (fallback)
      if (response is Map) {
        final result = response['result'];
        if (result is List) {
          return _parseTopicsResponse(result);
        }
      }

      return [];
    } catch (e, stackTrace) {
      print('Error in _parseTopicsResponse: $e');
      print('Stack trace: $stackTrace');
      print('Response type: ${response.runtimeType}');
      return [];
    }
  }

  /// Safely converts a single topic item to TopicsModel
  /// Handles Map<dynamic, dynamic> from JSON decoding
  TopicsModel? _mapTopicItem(dynamic item) {
    try {
      if (item == null) return null;

      // Handle Map type (could be Map<dynamic, dynamic> or Map<String, dynamic>)
      if (item is Map) {
        // Safely extract values, converting keys to strings
        String? id;
        String? name;
        String? icon;
        String type = 'topic'; // Default type

        // Extract id
        final idValue = item['id'];
        if (idValue != null) {
          id = idValue.toString();
        }

        // Extract name
        final nameValue = item['name'];
        if (nameValue != null) {
          name = nameValue.toString();
        }

        // Extract icon
        final iconValue = item['icon'];
        if (iconValue != null) {
          icon = iconValue.toString();
        }

        // Extract type if present
        final typeValue = item['type'];
        if (typeValue != null) {
          type = typeValue.toString();
        }

        // Only create model if we have at least id and name
        if (id != null && name != null) {
          return TopicsModel(
            id: id,
            name: name,
            icon: icon,
            type: type,
          );
        }
      }

      return null;
    } catch (e, stackTrace) {
      print('Error mapping topic item: $e');
      print('Stack trace: $stackTrace');
      print('Item: $item, type: ${item.runtimeType}');
      return null;
    }
  }
}

