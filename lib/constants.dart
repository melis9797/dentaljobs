const cities = [
  'İstanbul',
  'Ankara',
  'İzmir',
  'Bursa',
  'Antalya',
  'Adana',
  'Konya',
  'Gaziantep',
  'Kocaeli',
  'Mersin',
  'Diğer',
];

final cityOptions = {for (final c in cities) c: c};

/// Dental branches. `general` is used for staff dentists.
const specialties = <String, String>{
  'general': 'Genel diş hekimi',
  'orthodontics': 'Ortodonti',
  'endodontics': 'Endodonti',
  'periodontology': 'Periodontoloji',
  'oral_surgery': 'Ağız, diş ve çene cerrahisi',
  'pedodontics': 'Pedodonti',
  'prosthodontics': 'Protetik diş tedavisi',
  'restorative': 'Restoratif diş tedavisi',
};

/// Branches a specialist dentist can choose (everything except the generic role).
final specialistBranches = {
  for (final e in specialties.entries)
    if (e.key != 'general') e.key: e.value,
};

const jobProfiles = <String, String>{
  'staff': 'Staff diş hekimi',
  'specialist': 'Uzman diş hekimi',
};

const experienceLevels = <String, String>{
  'new_grad': 'Yeni mezun',
  'junior': '3 yıldan az deneyim',
  'senior': '3+ yıl deneyim',
};

const employmentTypes = <String, String>{
  'full_time': 'Tam zamanlı',
  'part_time': 'Yarı zamanlı',
  'freelance': 'Serbest',
};

const applicationStatuses = <String, String>{
  'new': 'Gönderildi',
  'seen': 'Görüldü',
  'accepted': 'Kabul edildi',
  'rejected': 'Reddedildi',
};

const itemTypes = <String, String>{
  'implant': 'İmplant',
  'equipment': 'Klinik ekipmanı',
};

const itemConditions = <String, String>{
  'new': 'Sıfır',
  'used': 'İkinci el',
};

/// 1250000 -> "1.250.000"
String groupThousands(int value) {
  final s = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}

String salaryText(int? min, int? max) {
  if (min == null && max == null) return 'Maaş belirtilmemiş';
  if (min != null && max != null) {
    return '${groupThousands(min)} – ${groupThousands(max)} ₺';
  }
  return '${groupThousands((min ?? max)!)} ₺';
}

String priceText(int? price) {
  if (price == null) return 'Fiyat görüşülür';
  return '${groupThousands(price)} ₺';
}

/// "Staff diş hekimi · Yeni mezun" or "Uzman diş hekimi · Ortodonti".
String jobProfileLabel(Map<String, dynamic> job) {
  final profile = job['job_profile'] as String? ?? 'staff';
  final detail = profile == 'staff'
      ? experienceLevels[job['experience_level']]
      : specialties[job['specialty']];
  return [jobProfiles[profile] ?? profile, if (detail != null) detail]
      .join(' · ');
}
