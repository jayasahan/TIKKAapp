class SupabaseConfig {
  const SupabaseConfig({
    required this.url,
    required this.anonKey,
    required this.authRedirectUrl,
  });

  static const SupabaseConfig fromEnvironment = SupabaseConfig(
    url: String.fromEnvironment('SUPABASE_URL'),
    anonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
    authRedirectUrl: String.fromEnvironment(
      'TIKKA_AUTH_REDIRECT_URL',
      defaultValue: 'tikka://auth-callback',
    ),
  );

  final String url;
  final String anonKey;
  final String authRedirectUrl;

  String? get errorMessage {
    final normalizedUrl = url.trim();
    final normalizedKey = anonKey.trim();
    final uri = Uri.tryParse(normalizedUrl);

    if (normalizedUrl.isEmpty ||
        normalizedKey.isEmpty ||
        normalizedUrl.contains('your-project-ref') ||
        normalizedKey.contains('replace-with-the-public-anon-key')) {
      return 'Add SUPABASE_URL and SUPABASE_ANON_KEY to a local Dart define file.';
    }

    if (uri == null ||
        !<String>{'https', 'http'}.contains(uri.scheme) ||
        uri.host.isEmpty) {
      return 'The Supabase URL is invalid. Check the local Supabase configuration.';
    }

    if (Uri.tryParse(authRedirectUrl)?.hasScheme != true) {
      return 'The authentication redirect URL is invalid.';
    }

    return null;
  }

  bool get isConfigured => errorMessage == null;
}
