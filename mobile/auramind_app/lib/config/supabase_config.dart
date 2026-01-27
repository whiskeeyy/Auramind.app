import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client configuration and initialization
class SupabaseConfig {
  // Singleton pattern
  static final SupabaseConfig _instance = SupabaseConfig._internal();
  factory SupabaseConfig() => _instance;
  SupabaseConfig._internal();

  static Future<void> initialize() async {
    // Load keys from .env (local) or build environment (CI/CD)
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ??
        const String.fromEnvironment('SUPABASE_URL');
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ??
        const String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
          'Supabase keys not found. Please create a .env file or pass them as build arguments.');
    }

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
