# Cursor Extensions & Development Tools Guide

## 🎯 Essential Cursor/VS Code Extensions for Flutter Development

### Core Flutter Development
1. **Dart** (by Dart Code Team)
   - Official Dart language support
   - Syntax highlighting, IntelliSense, debugging
   - Flutter integration

2. **Flutter** (by Dart Code Team)
   - Official Flutter extension
   - Hot reload, widget tree inspector
   - Flutter doctor integration

3. **Flutter Widget Snippets** (by Alexisvt)
   - Quick widget code snippets
   - Saves time on boilerplate

4. **Awesome Flutter Snippets** (by Nash)
   - Comprehensive Flutter code snippets
   - Stateful/Stateless widgets, providers, etc.

5. **Flutter Tree** (by Marcelovelasquez)
   - Visualize widget tree structure
   - Helps with complex layouts

### Code Quality & Formatting
6. **Dart Data Class Generator** (by Hrishikesh-kadam)
   - Auto-generate data classes
   - Reduces boilerplate

7. **Error Lens** (by Alexander)
   - Inline error highlighting
   - Real-time error detection

8. **Better Comments** (by Aaron Bond)
   - Enhanced comment highlighting
   - TODO, FIXME markers

9. **Todo Tree** (by Gruntfuggly)
   - Lists all TODO/FIXME comments
   - Keeps track of technical debt

10. **Code Spell Checker** (by Street Side Software)
    - Catches typos in code
    - Custom dictionaries for Flutter

### REST API & Backend Development
11. **REST Client** (by Huachao Mao)
    - Test REST APIs directly in VS Code
    - `.http` file support

12. **Thunder Client** (by Ranga Vadhineni)
    - Full-featured REST API client
    - Alternative to Postman

13. **Postman** (by Postman)
    - Official Postman integration
    - Import/export collections

### Firebase & Supabase
14. **Firebase Explorer** (by jsayol)
    - Browse Firebase projects
    - View data, functions, storage

15. **Supabase** (by Supabase)
    - Official Supabase extension
    - Database management, auth

### Docker & DevOps
16. **Docker** (by Microsoft)
    - Dockerfile syntax, build, run
    - Container management

17. **Docker Compose** (by Microsoft)
    - Multi-container orchestration
    - Compose file support

18. **Remote - Containers** (by Microsoft)
    - Develop inside containers
    - Consistent environments

### Database Tools
19. **PostgreSQL** (by Chris Kolkman)
    - PostgreSQL database management
    - Query editor, connection manager

20. **SQLTools** (by Matheus Teixeira)
    - Universal SQL client
    - Works with PostgreSQL, MySQL, etc.

21. **SQLTools PostgreSQL/Cockroach Driver** (by Matheus Teixeira)
    - PostgreSQL driver for SQLTools

### Git & Version Control
22. **GitLens** (by GitKraken)
    - Enhanced Git capabilities
    - Blame, history, file annotation

23. **Git Graph** (by mhutchie)
    - Visual Git graph
    - Branch management

### CI/CD & Automation
24. **GitHub Actions** (by GitHub)
    - GitHub Actions workflow editor
    - Syntax highlighting

25. **YAML** (by Red Hat)
    - YAML syntax support
    - Essential for CI/CD configs

### Code Generation & Productivity
26. **JSON to Dart** (by Hrishikesh-kadam)
    - Convert JSON to Dart models
    - Saves time on API integration

27. **Pubspec Assist** (by jeroen-meijer)
    - Quick package management
    - Add/update packages easily

28. **Flutter Intl** (by Localizely)
    - Internationalization support
    - Generate ARB files

### Testing & Debugging
29. **Flutter Coverage** (by ryanluker)
    - Code coverage visualization
    - Test coverage reports

30. **Test Explorer UI** (by Holger Benl)
    - Test runner UI
    - Run tests from sidebar

### Golang Development (for backend)
31. **Go** (by Go Team at Google)
    - Official Go extension
    - Language server, debugging

32. **Go Test** (by premparihar)
    - Run Go tests easily
    - Test coverage

### UI/UX Tools
33. **Color Highlight** (by Sergii Naumov)
    - Highlights color codes
    - Visual color preview

34. **Material Icon Theme** (by Philipp Kief)
    - Material Design icons
    - Better file tree visualization

35. **Bracket Pair Colorizer 2** (by CoenraadS)
    - Color matching brackets
    - Easier code reading

### Performance & Monitoring
36. **Performance Monitor** (by akamud)
    - Monitor VS Code performance
    - Resource usage

---

## 📦 Recommended Flutter Packages

### State Management (You're using Riverpod ✅)
- `flutter_riverpod` ✅ (already using)
- `riverpod_annotation` + `riverpod_generator` (code generation)
- `hooks_riverpod` (Riverpod + Flutter Hooks)

### Networking & REST API
- `dio` ✅ (already using)
- `retrofit` (Type-safe REST client generator)
- `json_serializable` + `json_annotation` (JSON serialization)
- `freezed` (Immutable data classes)
- `connectivity_plus` ✅ (already using)

### Firebase (You're using some ✅)
- `firebase_core` (Core Firebase)
- `firebase_messaging` ✅ (already using)
- `firebase_analytics` ✅ (already using)
- `firebase_dynamic_links` ✅ (already using)
- `firebase_auth` (Authentication)
- `firebase_storage` (File storage)
- `firebase_firestore` (NoSQL database)
- `firebase_crashlytics` (Crash reporting)
- `cloud_firestore` (Firestore)
- `firebase_remote_config` (Remote configuration)

### Supabase
- `supabase_flutter` (Official Supabase client)
- `supabase_auth_ui` (Pre-built auth UI)

### Database & Local Storage
- `hive` ✅ (already using)
- `hive_flutter` ✅ (already using)
- `sqflite` (SQLite database)
- `drift` (Type-safe SQLite ORM)
- `isar` (Fast NoSQL database)
- `shared_preferences` ✅ (already using)

### JSON & Serialization
- `json_serializable` (Code generation)
- `json_annotation` (Annotations)
- `freezed` (Immutable classes)
- `built_value` (Value types)

### Environment & Configuration
- `flutter_dotenv` (Environment variables)
- `config` (Configuration management)
- `package_info_plus` (App info)

### CI/CD & Build Tools
- `flutter_launcher_icons` ✅ (already using)
- `flutter_native_splash` ✅ (already using)
- `flutter_version` (Version management)
- `very_good_analysis` (Linting rules)

### Testing
- `mockito` (Mocking for tests)
- `mocktail` (Mocking without codegen)
- `golden_toolkit` (Golden file testing)
- `integration_test` (Integration tests)
- `flutter_test` ✅ (already using)

### Code Generation
- `build_runner` (Code generation runner)
- `freezed` (Immutable data classes)
- `json_serializable` (JSON serialization)
- `riverpod_generator` (Riverpod codegen)

### Platform-Specific
- `platform` (Platform detection)
- `device_info_plus` (Device information)
- `url_launcher` ✅ (already using)
- `share_plus` ✅ (already using)

### Performance & Monitoring
- `flutter_native_splits` (App bundle splitting)
- `sentry_flutter` (Error tracking)
- `firebase_performance` (Performance monitoring)

### Security
- `flutter_secure_storage` (Secure key-value storage)
- `crypto` (Cryptography)
- `local_auth` (Biometric authentication)

### Utilities
- `intl` ✅ (already using)
- `path_provider` ✅ (already using)
- `uuid` (UUID generation)
- `equatable` (Value equality)
- `cached_network_image` (Image caching)

---

## 🐳 Docker & Containerization

### Recommended Docker Extensions
1. **Docker** (by Microsoft) - Already mentioned above
2. **Docker Compose** (by Microsoft) - Already mentioned above

### Dockerfile Examples Needed
- Flutter web build
- Flutter multi-platform build
- PostgreSQL database
- Golang backend API

---

## 🔄 CI/CD Recommendations

### GitHub Actions
- **flutter_action** (Flutter workflow)
- **setup-node-action** (Node.js setup)
- **docker-build-push-action** (Docker builds)
- **deploy-action** (Deployment automation)

### Tools
- **Fastlane** (iOS/Android deployment)
- **Codemagic** (Flutter-specific CI/CD)
- **AppCircle** (Mobile CI/CD)
- **Bitrise** (Mobile CI/CD)

---

## 🗄️ PostgreSQL & Database Tools

### Recommended Extensions
- **PostgreSQL** (by Chris Kolkman) - Already mentioned
- **SQLTools** (by Matheus Teixeira) - Already mentioned

### Flutter Packages
- `postgres` (PostgreSQL driver)
- `drift` (Type-safe SQL ORM with PostgreSQL support)
- `sqljocky5` (MySQL driver - if needed)

---

## 🐹 Golang Development Tools

### VS Code Extensions
- **Go** (by Go Team at Google) - Already mentioned
- **Go Test** (by premparihar) - Already mentioned

### Recommended Go Packages (for backend)
- `github.com/gin-gonic/gin` (Web framework)
- `github.com/lib/pq` (PostgreSQL driver)
- `github.com/golang-migrate/migrate` (Database migrations)
- `github.com/joho/godotenv` (Environment variables)
- `github.com/dgrijalva/jwt-go` (JWT authentication)

---

## 📱 App Publishing Tools

### iOS
- **Xcode** (Required)
- **Fastlane** (Automation)
- **App Store Connect API**

### Android
- **Android Studio** (Optional, can use VS Code)
- **Fastlane** (Automation)
- **Google Play Console API**

### macOS
- **Xcode** (Required)
- **Notarization tools**

### Web
- **Firebase Hosting**
- **Vercel**
- **Netlify**
- **GitHub Pages**

---

## 🛠️ Development Workflow Tools

### Code Quality
- `flutter analyze` (Built-in)
- `dart fix --apply` (Built-in)
- `very_good_analysis` (Enhanced linting)

### Formatting
- `dart format` (Built-in)
- **Format Document** extension (Auto-format on save)

### Version Control
- **GitLens** - Already mentioned
- **Git Graph** - Already mentioned

---

## 📋 Recommended VS Code Settings

Add to your `.vscode/settings.json`:

```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "dart.enableSdkFormatter": true,
  "dart.lineLength": 80,
  "files.exclude": {
    "**/.git": true,
    "**/.svn": true,
    "**/.hg": true,
    "**/CVS": true,
    "**/.DS_Store": true,
    "**/Thumbs.db": true,
    "**/.dart_tool": true,
    "**/build": true
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/bower_components": true,
    "**/*.code-workspace": true,
    "**/.dart_tool": true,
    "**/build": true
  },
  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/.git/subtree-cache/**": true,
    "**/node_modules/**": true,
    "**/.dart_tool/**": true,
    "**/build/**": true
  }
}
```

---

## 🎯 Priority Installation Order

### Must Have (Immediate)
1. Dart + Flutter extensions
2. Error Lens
3. GitLens
4. REST Client or Thunder Client
5. Docker extension

### High Priority
6. Firebase Explorer
7. Supabase extension
8. SQLTools
9. Go extension (if using Golang backend)
10. JSON to Dart

### Nice to Have
11. Flutter Widget Snippets
12. Todo Tree
13. Code Spell Checker
14. Material Icon Theme

---

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Docker Documentation](https://docs.docker.com/)
- [Go Documentation](https://go.dev/doc/)

---

**Note**: This list is comprehensive. Start with the "Must Have" extensions and gradually add others based on your specific needs.

