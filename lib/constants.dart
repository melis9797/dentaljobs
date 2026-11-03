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

const specialties = <String, String>{
  'general': 'Genel diş hekimi',
  'orthodontics': 'Ortodonti',
  'endodontics': 'Endodonti',
  'periodontology': 'Periodontoloji',
  'oral_surgery': 'Ağız, diş ve çene cerrahisi',
  'pedodontics': 'Pedodonti',
  'prosthodontics': 'Protetik diş tedavisi',
  'restorative': 'Restoratif diş tedavisi',
  'assistant': 'Diş asistanı',
  'technician': 'Diş teknisyeni',
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

String salaryText(int? min, int? max) {
  if (min == null && max == null) return 'Maaş belirtilmemiş';
  if (min != null && max != null) return '$min – $max ₺';
  return '${min ?? max} ₺';
}
