import 'package:dental_jobs/constants.dart';
import 'package:dental_jobs/turkey_locations.dart';
import 'package:dental_jobs/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('salaryText formats ranges with thousand separators', () {
    expect(salaryText(null, null), 'Maaş belirtilmemiş');
    expect(salaryText(50000, 70000), '50.000 – 70.000 ₺');
    expect(salaryText(50000, null), '50.000 ₺');
  });

  test('priceText groups digits or falls back to negotiable', () {
    expect(priceText(null), 'Fiyat görüşülür');
    expect(priceText(0), '0 ₺');
    expect(priceText(1250000), '1.250.000 ₺');
  });

  test('jobProfileLabel describes staff and specialist jobs', () {
    expect(
      jobProfileLabel({'job_profile': 'staff', 'experience_level': 'new_grad'}),
      'Staff diş hekimi · Yeni mezun',
    );
    expect(
      jobProfileLabel({'job_profile': 'staff', 'experience_level': 'junior'}),
      'Staff diş hekimi · 3 yıldan az deneyim',
    );
    expect(
      jobProfileLabel({'job_profile': 'staff', 'experience_level': 'senior'}),
      'Staff diş hekimi · 3+ yıl deneyim',
    );
    expect(
      jobProfileLabel({'job_profile': 'specialist', 'specialty': 'orthodontics'}),
      'Uzman diş hekimi · Ortodonti',
    );
  });

  test('specialist branches exclude the generic staff branch', () {
    expect(specialistBranches.containsKey('general'), isFalse);
    expect(specialistBranches.containsKey('orthodontics'), isTrue);
  });

  test('all 81 provinces and 973 districts are present', () {
    expect(provinces.length, 81);
    expect(turkeyDistricts.values.fold<int>(0, (n, l) => n + l.length), 973);
    expect(provinces.first, 'Adana');
    expect(provinces.last, 'Zonguldak');
    expect(districtsOf('İstanbul').length, 39);
    expect(districtsOf('Ankara').length, 25);
    expect(districtsOf('İzmir').length, 30);
    expect(districtsOf(null), isEmpty);
    for (final entry in turkeyDistricts.entries) {
      expect(entry.value, isNotEmpty, reason: entry.key);
      expect(entry.value.toSet().length, entry.value.length, reason: entry.key);
    }
  });

  test('normalizeTr lets plain letters find Turkish names', () {
    expect(normalizeTr('İstanbul'), 'istanbul');
    expect(normalizeTr('Iğdır'), 'igdir');
    expect(normalizeTr('Şanlıurfa'), 'sanliurfa');
    expect(normalizeTr('Çanakkale'), 'canakkale');
  });

  test('phone and number validators', () {
    expect(cleanPhone('0555 000 00 00'), '05550000000');
    expect(phoneField('0555 000 00 00'), isNull);
    expect(phoneField('123'), isNotNull);
    expect(optionalNumber(''), isNull);
    expect(optionalNumber('abc'), isNotNull);
    expect(optionalNumberUpTo(100)('101'), isNotNull);
    expect(optionalNumberUpTo(100)('99'), isNull);
    expect(titleField('ab'), isNotNull);
    expect(titleField('Devren satılık klinik'), isNull);
  });
}
