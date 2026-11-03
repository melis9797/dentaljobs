import 'package:dental_jobs/constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('salaryText formats ranges', () {
    expect(salaryText(null, null), 'Maaş belirtilmemiş');
    expect(salaryText(50000, 70000), '50000 – 70000 ₺');
    expect(salaryText(50000, null), '50000 ₺');
  });
}
