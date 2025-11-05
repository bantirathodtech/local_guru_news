// 🏗️ REPOSITORY REFERENCE TEMPLATE
// 📌 Save this as a reference guide, not for direct use
// ⚠️ All repositories MUST follow these patterns

/*
// 1️⃣ BASIC IMPORTS (Always use these)
import 'package:get_it/get_it.dart';
import '../../core/api/endpoints/api_endpoints.dart';
import '../../core/api/service/api_service.dart';
import '../models/[feature]_model.dart'; // Replace with actual model

// 2️⃣ REPOSITORY CLASS STRUCTURE
class [Feature]Repository { // PascalCase
  final ApiService _apiService = GetIt.instance<ApiService>(); // Core DI

  // 3️⃣ GET EXAMPLE (List of items)
  Future<List<[Feature]Model>> get[Feature]s() async {
    // ✅ Core handles: URL, parsing, errors, logging
    final response = await _apiService.get(ApiEndpoints.[feature]s);

    // ✅ Only business logic:
    return (response as List)
        .map((item) => [Feature]Model.fromJson(item))
        .where((item) => item.isActive) // Filtering example
        .toList();
  }

  // 4️⃣ GET BY ID EXAMPLE (Single item)
  Future<[Feature]Model> get[Feature]ById(int id) async {
    // ✅ Core handles everything before this
    final response = await _apiService.get('${ApiEndpoints.[feature]s}/$id');
    return [Feature]Model.fromJson(response); // Pure conversion
  }

  // 5️⃣ POST EXAMPLE (Create new)
  Future<void> create[Feature]([Feature]Model newItem) async {
    // ✅ Core handles serialization
    await _apiService.post(
      ApiEndpoints.[feature]s,
      newItem.toJson(), // Model handles serialization
    );
  }

  // 6️⃣ FILE UPLOAD EXAMPLE
  Future<String> upload[Feature]Image(File image, int itemId) async {
    // ✅ Core handles multipart
    final response = await _apiService.postWithFile(
      ApiEndpoints.[feature]Images,
      {'item_id': itemId}, // Additional fields
      image,
      'image', // Form field name
    );
    return response['image_url']; // Extract value
  }

  // 7️⃣ BUSINESS LOGIC EXAMPLE
  Future<List<[Feature]Model>> getPremium[Feature]s() async {
    final allItems = await get[Feature]s();
    return allItems.where((item) => item.isPremium).toList();
  }
}
*/

// 8️⃣ ANNOTATED EXAMPLE (User Feature)
/*
class UserRepository {
  final ApiService _apiService = GetIt.instance<ApiService>();

  // ✅ Good: Pure business logic
  Future<List<UserModel>> getActiveUsers() async {
    final response = await _apiService.get(ApiEndpoints.users);
    return (response as List)
        .map(UserModel.fromJson)
        .where((user) => user.isActive)
        .toList();
  }

  // ❌ Bad: Avoid these patterns
  Future<UserModel> _badExample(int id) async {
    // ❌ Manual JSON parsing
    final response = await _apiService.get(ApiEndpoints.users);
    final data = jsonDecode(response); // Duplicates core functionality

    // ❌ Type checking
    if (data is! Map) throw Error(); // ApiResponse already handles

    // ❌ Custom error handling
    try {
      return UserModel.fromJson(data);
    } catch (e) {
      // ApiExceptions handles this
      throw Exception('Custom error');
    }
  }
}
*/

// 9️⃣ KEY PRINCIPLES TO REMEMBER
/*
✅ DO:
- Use ApiService for ALL network calls
- Delegate ALL parsing to core
- Keep ONLY business logic
- Follow consistent naming ([Feature]Repository)

❌ DON'T:
- Create new Dio instances
- Add jsonDecode() calls
- Implement custom error handling
- Put UI logic in repositories
*/
