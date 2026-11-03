# Dental Jobs

Flutter + Supabase iş ilanı uygulaması (diş hekimi, asistan, teknisyen, klinik).

## Kurulum

1. Flutter'ı kur: https://docs.flutter.dev/get-started/install
2. Bu klasörde platform dosyalarını oluştur (mevcut `lib/` ve `pubspec.yaml` korunur):

   ```
   flutter create --platforms=android,ios --project-name dental_jobs .
   flutter pub get
   ```

3. Çalıştır: `flutter run`
4. Kontrol: `flutter analyze` ve `flutter test`

## Önemli notlar

- Supabase bağlantısı `lib/config.dart` içinde. Publishable anahtar uygulamanın içinde
  durabilir; veriyi korumayı veritabanındaki satır güvenliği (RLS) kuralları yapar.
- **Android release:** `android/app/src/main/AndroidManifest.xml` içine
  `<uses-permission android:name="android.permission.INTERNET"/>` ekle. Yoksa mağaza
  sürümü internete bağlanamaz.
- **iOS:** derlemek için Mac ve Xcode gerekir.
- **E-posta doğrulama:** Supabase varsayılan olarak kayıtta e-posta doğrulaması ister.
  Denerken kapatmak için Supabase panelinde Authentication → Sign In / Providers → Email.
- Hesap türü `dentist` iş arayan herkesi kapsar (hekim, asistan, teknisyen).

## Ekranlar

- İlanlar: şehir ve branşa göre filtre, ilan detayı, başvuru
- Başvuru/İlan: iş arayan için başvurularım, klinik için ilanlarım ve gelen başvurular
- Profil: bilgileri düzenle, çıkış

## Bilgisayara Flutter kurmadan derleme (GitHub Actions)

`.github/workflows/build.yml` dosyası GitHub'ın sunucularında kodu analiz eder, testleri
çalıştırır ve Android APK üretir. Projeyi GitHub'a yükle (`.github` klasörü dahil), Actions
sekmesinden çalışmayı izle, bitince "dental-jobs-apk" dosyasını indir. APK imzasız
(debug anahtarlı) bir test sürümüdür; Google Play'e yüklemek için ayrıca imzalanmalıdır.
