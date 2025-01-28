import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '/auth/supabase_auth/supabase_user_provider.dart';
import '/flutter_flow/nav/nav.dart';

export 'database/database.dart';

String _kSupabaseUrl = 'XXXXXXXXXXXXXX';
String _kSupabaseAnonKey = 'XXXXXXXXXXXXXX';

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() async {
    await Supabase.initialize(
      url: _kSupabaseUrl,
      anonKey: _kSupabaseAnonKey,
      debug: false,
    );

    final session = Supabase.instance.client.auth.currentSession;
    print('[Supabase] Initial session: ${session != null ? 'exists' : 'null'}');
    if (session != null) {
      print('[Supabase] User ID: ${session.user.id}');
      // Create auth user wrapper and update app state
      // Initialize your auth here
	  //final authUser = FlutterAppSupabaseUser(session.user);
      //AppStateNotifier.instance.update(authUser);
    }
  }
}
