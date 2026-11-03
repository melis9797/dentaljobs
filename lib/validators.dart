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
