import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_screen.dart';
import 'screens/blog_join_screen.dart';
import 'supabase_client.dart';

class BlogMember {
  const BlogMember({required this.nickname, required this.banned});

  final String nickname;
  final bool banned;
}

Future<BlogMember?> fetchMyBlogMember() async {
  final user = supabase.auth.currentUser;
  if (user == null) return null;
  final row = await supabase
      .from('blog_members')
      .select('nickname,banned_at')
      .eq('user_id', user.id)
      .maybeSingle();
  if (row == null) return null;
  return BlogMember(
    nickname: row['nickname'] as String,
    banned: row['banned_at'] != null,
  );
}

Future<bool> fetchIsAdmin() async {
  if (supabase.auth.currentUser == null) return false;
  try {
    final result = await supabase.rpc('is_admin');
    return result == true;
  } catch (_) {
    return false;
  }
}

/// Columns anonymous visitors may read; signed-in members may also read
/// author id and the reason a post was hidden.
String entryColumns() => supabase.auth.currentUser == null
    ? 'id,topic_id,author_nickname,body,status,created_at'
    : 'id,topic_id,author_id,author_nickname,body,status,hidden_reason,created_at';

const topicColumns = 'id,title,author_nickname,status,created_at,last_entry_at';

const _errorTexts = <String, String>{
  'blog_rules_required': 'Önce takma adını seçip kuralları kabul etmelisin.',
  'blog_banned':
      'Topluluk kurallarını ihlal ettiğin için blog yazma yetkin kapatıldı.',
  'personal_data_detected':
      'Telefon, T.C. kimlik no gibi kişisel bilgiler paylaşılamaz. Yazını düzenle.',
  'rate_limited': 'Çok hızlı yazıyorsun. Biraz bekleyip tekrar dene.',
  'topic_unavailable': 'Bu başlık artık yazıya açık değil.',
  'nickname_taken': 'Bu takma ad alınmış, başka bir tane dene.',
  'nickname_reserved': 'Bu takma ad kullanılamaz, başka bir tane dene.',
  'invalid_nickname':
      'Takma ad 3-20 karakter olmalı; yalnızca a-z, 0-9 ve _ kullan.',
  'not_authenticated': 'Önce giriş yapmalısın.',
  'forbidden': 'Bu işlem için yetkin yok.',
};

/// Turns a database error into a short Turkish message for the user.
String blogErrorText(Object error) {
  final raw = error is PostgrestException ? error.message : error.toString();
  for (final entry in _errorTexts.entries) {
    if (raw.contains(entry.key)) return entry.value;
  }
  return 'Bir sorun oluştu. Biraz sonra tekrar dene.';
}

/// Makes sure the user is signed in and has picked a nickname. Returns true
/// when they can write.
Future<bool> ensureBlogMember(BuildContext context) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  if (supabase.auth.currentUser == null) {
    await navigator.push(MaterialPageRoute(builder: (_) => const AuthScreen()));
    if (supabase.auth.currentUser == null) return false;
  }
  BlogMember? me;
  try {
    me = await fetchMyBlogMember();
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Bağlantı sorunu. Tekrar dene.')),
    );
    return false;
  }
  if (me == null) {
    final joined = await navigator.push<bool>(
      MaterialPageRoute(builder: (_) => const BlogJoinScreen()),
    );
    return joined == true;
  }
  if (me.banned) {
    messenger.showSnackBar(SnackBar(content: Text(blogErrorText('blog_banned'))));
    return false;
  }
  return true;
}
