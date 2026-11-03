# Dental Jobs

Flutter + Supabase ilan uygulaması. Üç bölümü var:

- **İş ilanları:** Staff diş hekimi (yeni mezun, 3 yıldan az deneyim, 3+ yıl deneyim) ve uzman diş hekimi (branşa göre). Kliniklerin ilan verdiği, hekimlerin başvurduğu bölüm.
- **Klinik devir:** Devren satılık klinik ilanları (şehir, ünit sayısı, metrekare, fiyat).
- **İmplant / Ekipman:** Sıfır ya da ikinci el implant ve klinik ekipmanı satış ilanları.

## Yayın

Kod `main` dalına gönderilince GitHub Actions iki iş çalıştırır:

- `Build Android APK`: analiz, test ve Android APK (Actions → çalışma → Artifacts).
- `Deploy web to GitHub Pages`: web sürümünü yayınlar.

## Yerelde çalıştırma

```
flutter create --platforms=android,ios,web --project-name dental_jobs .
flutter pub get
flutter run
```

## Notlar

- Supabase bağlantısı `lib/config.dart` içinde. Publishable anahtar uygulamanın içinde durabilir; veriyi korumayı veritabanındaki satır güvenliği (RLS) kuralları yapar.
- Klinik devir ve ekipman ilanlarını giriş yapmış herkes verebilir, iş ilanlarını yalnızca klinik hesapları verebilir.
- Devir ve ekipman ilanlarındaki iletişim telefonu herkese görünür.
- **Android release:** `AndroidManifest.xml` içinde `INTERNET` izni olmalı (iş akışı bunu otomatik ekler).
- **E-posta doğrulama:** Denerken Supabase panelinde Authentication → Sign In / Providers → Email altından "Confirm email" kapatılabilir.
