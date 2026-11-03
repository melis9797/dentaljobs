import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get supabase => Supabase.instance.client;

/// The signed-in user's row from `profiles`, or null when signed out.
Future<Map<String, dynamic>?> fetchMyProfile() async {
  final user = supabase.auth.currentUser;
  if (user == null) return null;
  return supabase.from('profiles').select().eq('id', user.id).maybeSingle();
}
