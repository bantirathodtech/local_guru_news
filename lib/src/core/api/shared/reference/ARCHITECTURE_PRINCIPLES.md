Core Architecture Responsibilities

1. File Structure & Responsibilities

File
Responsibility
✅ Do's
❌ Don'ts

api_constants.dart
Network configurations
Timeouts, Headers, Content-Types
Business logic

api_endpoints.dart
Route management
Base URLs, Endpoint paths
Hardcoded URLs elsewhere

api_exceptions.dart
Error standardization
Convert all errors to ApiException
Silent error swallowing

api_logging.dart
Request/response tracking
Debug-mode only logs
Production logging

api_response.dart
Response processor
JSON parsing, Status code handling
Business logic

api_service.dart
Dio HTTP client
CRUD operations, File uploads
Response parsing

network_utils.dart
Connectivity checks
Online/offline detection
Network calls

2. Repository Principles
   ✅ Must Do

Use Existing Core Files  
// Good
final response = await _apiService.get(ApiEndpoints.users);

Pure Business Logic
// Filter active users
return users.where((u) => u.isActive).toList();

Model Conversion Only
// Simple conversion
return UserModel.fromJson(response);

❌ Never Do

Handle JSON Parsing
// BAD - Core already handles this
final data = jsonDecode(response);

Add Type Checks
// BAD - ApiResponse validates types
if (response is! Map) throw Error();

Implement Error Handling
// BAD - Core converts to ApiException
try { ... } catch (e) { /* custom handling */ }

3. Workflow: From Postman to Production

Step 1: Verify Endpoint

Add to api_endpoints.dart:

static const String users = '$baseUrl/users';

Step 2: Create Model
class User {
final int id;
final String name;

User.fromJson(Map<String,dynamic> json) :
id = json['id'] as int,
name = json['name'] as String;
}

Step 3: Implement Repository
class UserRepository {
final ApiService _apiService;

Future<List<User>> getActiveUsers() async {
final response = await _apiService.get(ApiEndpoints.users);
return (response as List).map(User.fromJson).where((u) => u.isActive);
}
}

4. Key Architecture Flow
   graph TD
   A[Repository] -->|Calls| B[ApiService]
   B -->|Uses| C[ApiEndpoints]
   B -->|Handles Errors| D[ApiExceptions]
   B -->|Logs| E[ApiLogger]
   B -->|Processes Response| F[ApiResponse]
   F -->|Validates| G[ApiStatusCodes]

5. Golden Rules

Core Files Handle:

Networking
Parsing
Errors
Logging

Repositories Handle:

Business rules
Model conversion
Data filtering

Models Handle:

Data representation
Serialization
Validation helpers

How to Use This

Keep ARCHITECTURE_PRINCIPLES.md in your project docs.
Refer to it when:
Creating new features
Onboarding team members
Reviewing pull requests

Example Workflow

Get Postman Response  
{ "id": 1, "title": "Sample" }

Create Model
class Sample {
final int id;
final String title;

Sample.fromJson(Map<String,dynamic> json) :
id = json['id'],
title = json['title'];
}

Implement Repository
class SampleRepository {
Future<Sample> getSample() async {
final response = await _apiService.get(ApiEndpoints.sample);
return Sample.fromJson(response);
}
}

This ensures 100% consistency with your architecture while eliminating guesswork!