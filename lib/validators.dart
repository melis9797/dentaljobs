String? requiredField(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Gerekli' : null;

String? titleField(String? v) {
  final t = v?.trim() ?? '';
  if (t.length < 3) return 'En az 3 karakter';
  if (t.length > 150) return 'En fazla 150 karakter';
  return null;
}

/// Empty is fine; otherwise it must be a whole number between 0 and 2 billion.
String? optionalNumber(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  final n = int.tryParse(v.trim());
  if (n == null || n < 0) return 'Sayı gir';
  if (n > 2000000000) return 'Çok büyük bir sayı';
  return null;
}

/// Like [optionalNumber] but with a custom upper limit.
String? Function(String?) optionalNumberUpTo(int max) {
  return (String? v) {
    final base = optionalNumber(v);
    if (base != null) return base;
    final n = int.tryParse((v ?? '').trim());
    if (n != null && n > max) return 'En fazla $max';
    return null;
  };
}

/// Keeps digits and a leading plus, so "0555 000 00 00" becomes "05550000000".
String cleanPhone(String text) => text.replaceAll(RegExp(r'[^0-9+]'), '');

String? phoneField(String? v) {
  final digits = cleanPhone(v ?? '');
  if (digits.length < 7 || digits.length > 20) {
    return 'Geçerli bir telefon numarası gir';
  }
  return null;
}

String? nullIfEmpty(String text) {
  final t = text.trim();
  return t.isEmpty ? null : t;
}

final _nicknamePattern = RegExp(r'^[a-z0-9_]{3,20}$');

String normalizeNickname(String v) => v.trim().toLowerCase();

String? nicknameField(String? v) {
  if (_nicknamePattern.hasMatch(normalizeNickname(v ?? ''))) return null;
  return 'Takma ad 3-20 karakter olmalı; yalnızca a-z, 0-9 ve _ kullan';
}

/// Telefon, T.C. kimlik no gibi 10+ haneli rakam dizilerini yakalar.
/// Sunucudaki kontrolün aynısıdır; asıl kontrol veritabanında yapılır.
bool containsPersonalData(String text) {
  final stripped = text.replaceAll(RegExp(r'[\s.()+\-]'), '');
  return RegExp(r'[0-9]{10,}').hasMatch(stripped);
}

String? blogTitleField(String? v) {
  final t = (v ?? '').trim();
  if (t.length < 3) return 'Başlık en az 3 karakter olmalı';
  if (t.length > 120) return 'Başlık en fazla 120 karakter olabilir';
  if (containsPersonalData(t)) {
    return 'Telefon, T.C. kimlik no gibi kişisel bilgiler yazılamaz';
  }
  return null;
}

String? blogBodyField(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return 'Bir şeyler yaz';
  if (t.length > 2000) return 'En fazla 2000 karakter yazabilirsin';
  if (containsPersonalData(t)) {
    return 'Telefon, T.C. kimlik no gibi kişisel bilgiler yazılamaz';
  }
  return null;
}
