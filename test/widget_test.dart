import 'package:dental_jobs/blog_service.dart';
import 'package:dental_jobs/constants.dart';
import 'package:dental_jobs/legal_texts.dart';
import 'package:dental_jobs/turkey_locations.dart';
import 'package:dental_jobs/validators.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  test('nickname rules: 3-20 chars of a-z, 0-9, underscore', () {
    expect(nicknameField('dis_hekimi34'), isNull);
    expect(nicknameField('  DisHekimi  '), isNull);
    expect(nicknameField('ab'), isNotNull);
    expect(nicknameField('a' * 21), isNotNull);
    expect(nicknameField('dr ali'), isNotNull);
    expect(nicknameField('doktor.ali'), isNotNull);
    expect(nicknameField('şükrü'), isNotNull);
    expect(nicknameField(''), isNotNull);
    expect(normalizeNickname('  DisHekimi '), 'dishekimi');
  });

  test('personal data check catches phone and national id numbers', () {
    expect(containsPersonalData('05551234567'), isTrue);
    expect(containsPersonalData('0555 123 45 67'), isTrue);
    expect(containsPersonalData('+90 (555) 123-45-67'), isTrue);
    expect(containsPersonalData('T.C. 12345678901'), isTrue);
    expect(containsPersonalData('2024 yılında 150 hasta baktım'), isFalse);
    expect(containsPersonalData('Fiyat 1.250.000 TL'), isFalse);
    expect(containsPersonalData('Implant fiyatları 4500 ile 9000 arası'), isFalse);
  });

  test('blog title and body validators', () {
    expect(blogTitleField('Yeni mezun maaşları'), isNull);
    expect(blogTitleField('ab'), isNotNull);
    expect(blogTitleField('a' * 121), isNotNull);
    expect(blogTitleField('Beni ara 05551234567'), isNotNull);
    expect(blogBodyField('Merhaba'), isNull);
    expect(blogBodyField('   '), isNotNull);
    expect(blogBodyField('a' * 2001), isNotNull);
    expect(blogBodyField('Hasta tel: 0555 123 45 67'), isNotNull);
  });

  test('database errors become Turkish messages', () {
    expect(
      blogErrorText(PostgrestException(message: 'rate_limited')),
      contains('hızlı'),
    );
    expect(
      blogErrorText(PostgrestException(message: 'personal_data_detected')),
      contains('kişisel'),
    );
    expect(
      blogErrorText(PostgrestException(message: 'nickname_taken')),
      contains('alınmış'),
    );
    expect(blogErrorText('blog_banned'), contains('yetkin'));
    expect(blogErrorText(Exception('something else')), contains('sorun'));
  });

  test('report reasons match the database check constraint', () {
    expect(
      reportReasons.keys.toSet(),
      {'patient_info', 'insult', 'false_info', 'spam', 'other'},
    );
  });

  test('dateTimeText formats local timestamps', () {
    expect(dateTimeText('2026-11-03T10:05:00'), '03.11.2026 10:05');
    expect(dateTimeText(null), '');
    expect(dateTimeText('not a date'), '');
  });

  test('legal documents have content', () {
    for (final doc in [communityRules, termsOfUse, privacyNotice, contactAndReports]) {
      expect(doc.title, isNotEmpty);
      expect(doc.sections, isNotEmpty, reason: doc.title);
      for (final section in doc.sections) {
        expect(section.heading, isNotEmpty);
        expect(section.body, isNotEmpty, reason: section.heading);
      }
    }
    final privacyText = privacyNotice.sections.map((s) => s.body).join(' ');
    expect(privacyText, contains('KVKK'));
  });
}
