import '/backend/supabase/supabase.dart';
import 'supabase_auth_manager.dart';

export 'supabase_auth_manager.dart';

final _authManager = SupabaseAuthManager();
SupabaseAuthManager get authManager => _authManager;

String get currentUserEmail => currentUser?.email ?? '';

String get currentUserUid => SupaFlow.client.auth.currentUser?.id ?? '';

String get currentUserDisplayName => currentUser?.displayName ?? '';

String get currentUserPhoto => currentUser?.photoUrl ?? '';

String get currentPhoneNumber => currentUser?.phoneNumber ?? '';

String get currentJwtToken => _currentJwtToken ?? '';

bool get currentUserEmailVerified => currentUser?.emailVerified ?? false;

/// Create a Stream that listens to the current user's JWT Token.
String? _currentJwtToken;
final jwtTokenStream = SupaFlow.client.auth.onAuthStateChange
    .map(
      (authState) => _currentJwtToken = authState.session?.accessToken,
    )
    .asBroadcastStream();

/// Get whether the current user is authenticated with Supabase
bool get isUserAuthenticated => SupaFlow.client.auth.currentUser != null;

/// Check if the current user has completed onboarding
Future<bool> isUserOnboarded() async {
  if (!isUserAuthenticated) return false;

  try {
    final response = await UserAccountsTable().queryRows(
      queryFn: (q) => q.eq('auth_user_id', currentUserUid),
    );

    if (response.isEmpty) return false;
    return response.first.isOnboarded ?? false;
  } catch (e) {
    print('[isUserOnboarded] Error: $e');
    return false;
  }
}

/// Set the onboarding status for the current user
Future<void> setUserOnboardingStatus(bool isOnboarded) async {
  if (!isUserAuthenticated) return;

  await UserAccountsTable().update(
    data: {'is_onboarded': isOnboarded},
    matchingRows: (q) => q.eq('auth_user_id', currentUserUid),
  );
}
