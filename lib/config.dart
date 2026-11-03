// Supabase project: dental-jobs (eu-central-1).
// The publishable key is meant to be shipped inside the app. Access is
// protected by the row level security policies in the database.
const supabaseUrl = 'https://yaibnbmikjpppdetvptg.supabase.co';
const supabasePublishableKey = 'sb_publishable_BL_b_LcuQAO6_PY4oOjFlw_debBgFxw';

// Sitenin işleticisi. Yasal sayfalarda (iletişim, aydınlatma metni) herkese
// görünür. Ad ve e-posta doldurulmadan Blog sekmesi açılmaz.
//
// DİKKAT: Aşağıdakiler TEST değerleridir (example.com gerçek bir kutuya
// gitmez). Avukat kontrolünden sonra gerçek bilgilerle değiştirilmeden
// uygulama yayınlanmamalı.
const legalOperatorName = 'Dental Jobs (TEST SÜRÜMÜ)';
const legalContactEmail = 'ornek@example.com';
const legalAddress = '';

/// Blog yalnızca işletici bilgileri girildiyse açılır (5651 sayılı Kanun,
/// yer sağlayıcının iletişim bilgilerini gösterme yükümlülüğü).
bool get blogEnabled =>
    legalOperatorName.trim().isNotEmpty && legalContactEmail.trim().isNotEmpty;
