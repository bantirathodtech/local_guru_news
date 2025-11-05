// State Management Architecture Principles (Provider Edition)
// This document outlines the standards for creating feature-specific state management files using Provider in the Medycart app (or any app using the core architecture). It builds on existing repositories and models, ensuring integration with core API principles. Focus is on a single [feature]_provider.dart file per feature for state management.
// 1. File Structure & Responsibilities
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// FileResponsibility✅ Do's❌ Don'ts[feature]_provider.dartState holding & notificationsChangeNotifier logic, provider declaration, business rulesDirect API calls, UI logic, model/repository code
// File Details
//
// [feature]_provider.dart: Single file containing the ChangeNotifier class for state logic (e.g., loading, data, error) and the Provider declaration. Use private state variables, public getters, and notifyListeners() for updates. Inject repositories via GetIt for data ops.
//
// 2. Principles for Creating [feature]_provider.dart
// ✅ Must Do
//
// Single File per Feature: Consolidate notifier and provider in one file named [feature]_provider.dart (e.g., user_provider.dart).
// Extend ChangeNotifier: Hold state in private fields, expose via getters, and call notifyListeners() after changes.
// dartclass [Feature]Notifier extends ChangeNotifier {
// List<[Feature]Model> _data = [];
// bool _isLoading = false;
// String? _error;
//
// List<[Feature]Model> get data => _data;
// bool get isLoading => _isLoading;
// String? get error => _error;
//
// final [Feature]Repository _repository = GetIt.instance<[Feature]Repository>();
//
// Future<void> fetchData() async {
// _isLoading = true;
// notifyListeners();
// try {
// _data = await _repository.get[Feature]s();
// _error = null;
// } catch (e) {
// _error = e.toString();
// } finally {
// _isLoading = false;
// notifyListeners();
// }
// }
// }
//
// Provider Declaration: Define at the bottom of the file.
// dartfinal [feature]Provider = ChangeNotifierProvider<[Feature]Notifier>((ref) => [Feature]Notifier());
//
// Integrate with Core: Use repositories for all data operations; rely on core for networking, parsing, errors.
// Business Logic Only: Handle filtering, transformations in notifier methods.
// Initial Fetch: Optionally call fetch in constructor if needed.
//
// ❌ Never Do
//
// Multiple Files: Do not split into separate state/notifier/provider files.
// Direct API Calls: Always go through repositories.
// dart// BAD
// final response = await _apiService.get(...);
//
// Mutable Public State: Use private fields and getters; no direct mutations without notification.
// UI-Specific Code: No context, widgets, or navigation in the file.
// Custom Error/Parsing: Let core handle exceptions and JSON.
//
// 3. Workflow for Creating [feature]_provider.dart
// Step 1: Ensure Prerequisites
//
// Model ([feature]_model.dart) with fromJson/toJson.
// Repository ([feature]_repository.dart) following core template.
//
// Step 2: Implement Notifier
//
// Define private state (e.g., _data, _isLoading, _error).
// Add getters.
// Inject repository via GetIt.
// Implement methods like fetch, create, with try-catch and notifications.
//
// Step 3: Add Provider
//
// Declare ChangeNotifierProvider at file end.
//
// Step 4: Use in App
//
// Wrap widgets with ChangeNotifierProvider or use MultiProvider.
// Consume with Consumer<[Feature]Notifier> or context.watch.
//
// 4. Key Architecture Flow
// Invalid diagram syntax.
// 5. Golden Rules
//
// File Handles: State variables, logic, notifications, provider setup.
// Reuses Core/Repos: For data, errors, logging.
// Keeps Simple: One file, focused on state changes.
// Consistent Naming: [feature]_provider.dart, [Feature]Notifier, [feature]Provider.
//
// 6. How to Use This
//
// Reference this MD when creating/reviewing feature providers.
// Aligns with existing repository MD/reference for consistency.
// Applicable to any app using the core architecture.
//
// // 🏗️ FEATURE PROVIDER REFERENCE TEMPLATE
// // 📌 Save this as [feature]_provider.dart
// // ⚠️ Single file for state management with Provider; integrates with core repos
// import 'package:flutter/foundation.dart';
// import 'package:provider/provider.dart';
// import 'package:get_it/get_it.dart';
// import '../models/[feature]_model.dart'; // Replace with actual model
// import '../repositories/[feature]_repository.dart'; // Separate repo file
// // 1️⃣ NOTIFIER CLASS (Holds state and logic)
// class [Feature]Notifier extends ChangeNotifier {
// // Private state variables
// List<[Feature]Model> _data = [];
// bool _isLoading = false;
// String? _error;
// // Public getters
// List<[Feature]Model> get data => _data;
// bool get isLoading => _isLoading;
// String? get error => _error;
// // Repository injection
// final [Feature]Repository _repository = GetIt.instance<[Feature]Repository>();
// // Optional initial fetch in constructor
// [Feature]Notifier() {
// fetch[Feature]s(); // Example: Load data on init
// }
// // Fetch method example
// Future<void> fetch[Feature]s() async {
// _isLoading = true;
// _error = null;
// notifyListeners(); // Notify start of loading
// try {
// _data = await _repository.get[Feature]s();
// } catch (e) {
// _error = e.toString();
// } finally {
// _isLoading = false;
// notifyListeners(); // Notify end
// }
// }</void>
// // Create method example
// Future<void> create[Feature]([Feature]Model newItem) async {
// try {
// await _repository.create<a href="newItem">Feature</a>;
// await fetch[Feature]s(); // Refresh data
// } catch (e) {
// _error = e.toString();
// notifyListeners();
// }
// }</void>
// // Business logic example (synchronous filtering)
// List<[Feature]Model> getFiltered[Feature]s(bool isPremium) {
// return _data.where((item) => item.isPremium == isPremium).toList();
// }
// }
// // 2️⃣ PROVIDER DECLARATION
// final [feature]Provider = ChangeNotifierProvider<[Feature]Notifier>((ref) => [Feature]Notifier());
// // 3️⃣ ANNOTATED EXAMPLE (User Feature)
// class UserNotifier extends ChangeNotifier {
// List<usermodel> _users = [];
// bool _isLoading = false;
// String? _error;</usermodel>
// List<usermodel> get users => _users;
// bool get isLoading => _isLoading;
// String? get error => _error;</usermodel>
// final UserRepository _repository = GetIt.instance<userrepository>();</userrepository>
// UserNotifier() {
// fetchUsers();
// }
// Future<void> fetchUsers() async {
// _isLoading = true;
// notifyListeners();
// try {
// _users = await _repository.getActiveUsers();
// _error = null;
// } catch (e) {
// _error = e.toString();
// } finally {
// _isLoading = false;
// notifyListeners();
// }
// }
// }</void>
// final userProvider = ChangeNotifierProvider<usernotifier>((ref) => UserNotifier());</usernotifier>
// // 4️⃣ BAD EXAMPLES (Avoid these)
// class BadNotifier extends ChangeNotifier {
// Future<void> badFetch() async {
// // ❌ Direct core bypass
// final api = GetIt.instance<apiservice>();
// await api.get('...'); // Use repo instead</apiservice></void>
// // ❌ No notification
// _users = []; // Missing notifyListeners()
// // ❌ UI code
// // Navigator.push(...); // No UI here
// }
// }
// // 5️⃣ KEY PRINCIPLES
// /*
// ✅ DO:
//
// Use private state with public getters
// Call notifyListeners() after every change
// Inject repos via GetIt
// Keep all in one file
// Delegate data to repos/core
//
// ❌ DON'T:
//
// Split into multiple files
// Mutate without notification
// Add direct API calls
// Include UI/navigation
// Handle errors/parsing (core does)
// */
