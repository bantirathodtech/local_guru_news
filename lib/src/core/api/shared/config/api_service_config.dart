class ApiServiceConfig {
  final bool enableLogging;
  final bool enableRetry;
  final bool enableRequestId;
  final bool enableTracking;

  // Optional: base URL of a CORS proxy to be used only on Flutter Web.
  // Example: https://cors.isomorphic-git.org/ or your own proxy like http://localhost:8080/proxy?url=
  final String? corsProxyBase;

  const ApiServiceConfig({
    this.enableLogging = true,
    this.enableRetry = true,
    this.enableRequestId = true,
    this.enableTracking = true,
    this.corsProxyBase,
  });

  /// Build from --dart-define values (non-breaking). For example:
  /// flutter run -d chrome --dart-define=CORS_PROXY_BASE=https://cors.isomorphic-git.org/
  factory ApiServiceConfig.fromEnvironment() {
    const cors = String.fromEnvironment('CORS_PROXY_BASE');
    return ApiServiceConfig(
      corsProxyBase: cors.isEmpty ? null : cors,
    );
  }
}
