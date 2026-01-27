import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client configuration and initialization
class SupabaseConfig {
  // Singleton pattern
  static final SupabaseConfig _instance = SupabaseConfig._internal();
  factory SupabaseConfig() => _instance;
  SupabaseConfig._internal();

  static Future<void> initialize() async {
    // TODO: Move these to environment variables for production
    // For now, using constants (NEVER commit real keys to git!)
    const supabaseUrl = 'https://rofkecleciqfyvqtdrgh.supabase.co';
    const supabaseAnonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'YOUR_SUPABASE_ANON_KEY_HERE', // Replace with actual key
    );

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce, // More secure auth flow
      ),
    );
  }

  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
}
