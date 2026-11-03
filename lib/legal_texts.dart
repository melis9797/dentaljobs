import 'config.dart';

/// A titled block of text inside a legal page.
class LegalSection {
  const LegalSection(this.heading, this.body);

  final String heading;
  final String body;
}

class LegalDoc {
  const LegalDoc(this.title, this.sections);

  final String title;
  final List<LegalSection> sections;
}

String _operatorBlock() {
  final lines = <String>[
    if (legalOperatorName.trim().isNotEmpty) legalOperatorName.trim(),
    if (legalAddress.trim().isNotEmpty) legalAddress.trim(),
    if (legalContactEmail.trim().isNotEmpty) 'E-posta: ${legalContactEmail.trim()}',
  ];
  return lines.isEmpty ? '' : lines.join('\n');
}

String _contactLine() => legalContactEmail.trim().isEmpty
    ? 'iletişim sayfasındaki adrese'
    : legalContactEmail.trim();

final communityRules = LegalDoc('Topluluk kuralları', [
  const LegalSection(
    'Bu alan ne için?',
    'Blog; diş hekimlerinin meslek, klinik yönetimi, ekipman ve kariyer üzerine '
        'konuştuğu bir yer. Herkes yazdığı şeyden kendisi sorumludur.',
  ),
  const LegalSection(
    '1. Hasta bilgisi paylaşma',
    'Hasta adı, soyadı, T.C. kimlik numarası, telefon, adres, dosya numarası, '
        'röntgen veya fotoğraf gibi bir kişiyi belirleyebilecek hiçbir bilgiyi '
        'yazma. Vakalardan söz edeceksen kimliği çıkarılamayacak şekilde, genel '
        'olarak anlat. Sağlık verisi özel nitelikli kişisel veridir; ihlal '
        'edenin yazısı gizlenir.',
  ),
  const LegalSection(
    '2. Hakaret, iftira ve tehdit yok',
    'Kişilere, kliniklere, firmalara veya meslektaşlara hakaret etme; '
        'kanıtlayamayacağın suçlamalar yapma; tehdit veya nefret söylemi '
        'kullanma. Eleştirini somut ve saygılı yaz.',
  ),
  const LegalSection(
    '3. Reklam ve spam yok',
    'Aynı mesajı tekrar tekrar yazma, toplu reklam veya yönlendirme yapma. '
        'İlan vermek için İlanlar bölümünü kullan.',
  ),
  const LegalSection(
    '4. Kimlik taklidi yok',
    'Başkası gibi davranma, başkasının adına yazma.',
  ),
  const LegalSection(
    '5. Tıbbi bilgi',
    'Burada yazılanlar genel sohbettir; hastaya özel tedavi tavsiyesi veya '
        'resmi görüş değildir.',
  ),
  const LegalSection(
    '6. Hukuka aykırı içerik',
    'Müstehcen, yasa dışı veya başkalarının haklarını ihlal eden içerik '
        'paylaşma.',
  ),
  const LegalSection(
    'Takma ad ve kayıtlar',
    'Yazıların takma adınla görünür; takma adın sonradan değiştirilemez. '
        'Ancak yazı, yazma zamanı ve bağlantı bilgisi (IP adresi) sistemde '
        'kayıtlı tutulur. Mahkeme veya yetkili makam talep ederse bu bilgiler '
        'kanuna uygun şekilde paylaşılabilir.',
  ),
  const LegalSection(
    'Şikayet ve yaptırımlar',
    'Her yazının yanındaki bayrak düğmesiyle şikayet edebilirsin. Üç farklı '
        'üyeden şikayet alan yazı, yönetici incelemesine kadar otomatik '
        'gizlenir. Yönetici kurallara aykırı yazıyı gizler; tekrarlayan '
        'ihlallerde yazma yetkisi kapatılır. Yazını kendin de silebilirsin.',
  ),
]);

final termsOfUse = LegalDoc('Kullanım koşulları', [
  LegalSection(
    'Hizmet sağlayıcı',
    _operatorBlock().isEmpty
        ? 'Dental Jobs; diş hekimleri ve klinikler için iş, klinik devir ve '
            'ekipman ilanları ile bir topluluk alanı sunan bir platformdur.'
        : 'Dental Jobs; diş hekimleri ve klinikler için iş, klinik devir ve '
            'ekipman ilanları ile bir topluluk alanı sunan bir platformdur. '
            'İşletici:\n${_operatorBlock()}',
  ),
  const LegalSection(
    'Platformun rolü',
    'Platform ilanlar ve blog yazıları için yer sağlar. İlanları ve yazıları '
        'önceden denetlemez; içeriğin doğruluğundan ve hukuka uygunluğundan '
        'içeriği yayınlayan kullanıcı sorumludur. Platform; bildirim aldığında '
        'veya kuralların ihlalini fark ettiğinde ilgili içeriği gizleyebilir '
        'veya kaldırabilir.',
  ),
  const LegalSection(
    'Hesap',
    'Hesap oluştururken doğru bilgi vermeli ve şifreni korumalısın. Bir '
        'kişinin birden fazla hesapla kuralları dolanması yasaktır. Hesabını '
        'dilediğin zaman Profil sayfasından silebilirsin.',
  ),
  const LegalSection(
    'İlanlar',
    'İlan veren, ilandaki bilgilerin doğru ve güncel olmasından, iş veya '
        'satış sözleşmesinden ve ilgili mevzuata uyumdan sorumludur. Platform '
        'taraflar arasındaki iş görüşmesinin, devrin veya satışın tarafı '
        'değildir.',
  ),
  const LegalSection(
    'Yasak kullanım',
    'Topluluk kurallarına aykırı içerik, sahte ilan, başkasının bilgisini izinsiz '
        'paylaşma ve sistemi bozmaya yönelik davranışlar yasaktır. İhlalde '
        'içerik kaldırılır, hesap kısıtlanabilir veya kapatılabilir.',
  ),
  const LegalSection(
    'Sorumluluğun sınırı',
    'Platform hizmeti olduğu gibi sunulur; kesintisiz veya hatasız '
        'olacağı garanti edilmez. Kullanıcıların birbirleriyle yaptığı '
        'anlaşmalardan doğan zararlardan platform, kanunun izin verdiği ölçüde '
        'sorumlu tutulamaz.',
  ),
  const LegalSection(
    'Değişiklik',
    'Bu koşullar güncellenebilir. Güncel sürüm uygulamada yayınlanır.',
  ),
]);

final privacyNotice = LegalDoc('Aydınlatma metni ve gizlilik', [
  LegalSection(
    'Veri sorumlusu',
    _operatorBlock().isEmpty
        ? '6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) kapsamında '
            'veri sorumlusu, uygulamayı işleten kişidir.'
        : '6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) kapsamında '
            'veri sorumlusu:\n${_operatorBlock()}',
  ),
  const LegalSection(
    'İşlenen veriler',
    '• Hesap: e-posta, ad soyad, hesap türü.\n'
        '• Profil: telefon, şehir, branş, kısa özgeçmiş (girersen).\n'
        '• İlanlar ve başvurular: ilan içeriği, iletişim telefonu, başvuru '
        'mesajı.\n'
        '• Blog: takma ad, yazılar, şikayetler.\n'
        '• Teknik kayıtlar: blog yazılarını gönderirken IP adresi ve zaman '
        'bilgisi.\n\n'
        'Profilindeki özgeçmiş ve ilan açıklamalarına sağlık verisi veya hasta '
        'bilgisi yazma.',
  ),
  const LegalSection(
    'Amaç ve hukuki sebep',
    'Verilerin; üyelik ve ilan hizmetini sunmak (sözleşmenin kurulması ve '
        'ifası), platformu güvenli tutmak ve kötüye kullanımı önlemek (meşru '
        'menfaat), 5651 sayılı Kanun gibi mevzuattan doğan yükümlülükleri '
        'yerine getirmek (hukuki yükümlülük) ve bir hakkın korunması için '
        'işlenir.',
  ),
  const LegalSection(
    'Kimlerle paylaşılır?',
    '• İlana başvurduğunda, başvuru bilgilerin o ilanı veren klinikle '
        'paylaşılır.\n'
        '• İlanlara koyduğun iletişim telefonu herkese açık görünür.\n'
        '• Blogda takma adın ve yazıların herkese açık görünür; kimliğin '
        'diğer kullanıcılara gösterilmez.\n'
        '• Mahkeme veya yetkili kamu kurumu yasal yoldan talep ederse ilgili '
        'bilgiler paylaşılabilir.',
  ),
  const LegalSection(
    'Verilerin saklandığı yer',
    'Veriler; Supabase altyapısında Almanya (Frankfurt) bölgesindeki '
        'sunucularda saklanır, web sürümü GitHub Pages üzerinden sunulur. '
        'Yani verilerin yurt dışında barındırılması söz konusudur.',
  ),
  const LegalSection(
    'Saklama süresi',
    'Verilerin hesabın açık olduğu sürece saklanır; hesabını silersen '
        'hesabına bağlı profil, ilan, başvuru ve blog verilerin silinir. '
        'Yasal saklama yükümlülüğü olan kayıtlar (ör. internet trafik '
        'bilgisi) mevzuatın öngördüğü süre boyunca tutulabilir.',
  ),
  LegalSection(
    'Haklarınız',
    'KVKK madde 11 uyarınca; verilerinin işlenip işlenmediğini öğrenme, '
        'bilgi talep etme, düzeltilmesini veya silinmesini isteme, itiraz '
        'etme ve zarar halinde tazminat talep etme hakkına sahipsin. '
        'Başvurunu ${_contactLine()} üzerinden yapabilirsin.',
  ),
  const LegalSection(
    'Çerezler ve yerel depolama',
    'Uygulama reklam veya izleme çerezi kullanmaz. Oturumunu açık tutmak için '
        'tarayıcının yerel depolamasında oturum bilgisi saklanır.',
  ),
]);

final contactAndReports = LegalDoc('İletişim ve içerik bildirimi', [
  LegalSection(
    'İletişim',
    _operatorBlock().isEmpty
        ? 'İletişim bilgileri yakında yayınlanacak.'
        : _operatorBlock(),
  ),
  LegalSection(
    'Hukuka aykırı içerik bildirimi',
    'Bir yazının veya ilanın hukuka aykırı olduğunu ya da kişilik haklarını '
        'ihlal ettiğini düşünüyorsan ${_contactLine()} adresine; içeriğin '
        'başlığını, hangi yönden hukuka aykırı olduğunu ve kendi iletişim '
        'bilgilerini yaz. Uygulamadaki üyeler ayrıca yazının yanındaki bayrak '
        'düğmesini kullanabilir. Bildirimler gecikmeden incelenir; hukuka '
        'aykırı bulunan içerik kaldırılır.',
  ),
  LegalSection(
    'Kişisel veri ve hesap silme talebi',
    'Hesabını Profil sayfasından silebilirsin. Silemiyorsan veya KVKK '
        'kapsamında başka bir talebin varsa ${_contactLine()} adresine yaz.',
  ),
]);
