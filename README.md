# Edebiyat Yarışmaları

## Yazarlar
sabahattin ali
https://edebiyatyarismalari.com/sabahattin-ali-yarismalari/
      
rıfat ılgaz
https://edebiyatyarismalari.com/rifat-ilgaz-yarismalari/

attila ilhan
https://edebiyatyarismalari.com/attila-ilhan-yarismalari/

cemal süreya
https://edebiyatyarismalari.com/cemal-sureya-yarismalari/

mehmet akif ersoy
https://edebiyatyarismalari.com/mehmet-akif-ersoy-yarismalari/

ahmet hamdi tanpınar
https://edebiyatyarismalari.com/ahmet-hamdi-tanpinar-yarismalari/

ömer seyfettin
https://edebiyatyarismalari.com/omer-seyfettin-yarismalari/

reşat nuri güntekin
https://edebiyatyarismalari.com/resat-nuri-guntekin-yarismalari/

sait faik abasıyanık
https://edebiyatyarismalari.com/sait-faik-abasiyanik-yarismalari/

fakir baykurt
https://edebiyatyarismalari.com/fakir-baykurt-yarismalari/

## Local Serve
- install ruby
- gem install bundler
- bundle install
- jekyll serve

## Evergreen Yarışmalar (Her Yıl Tekrarlanan Yarışmalar)

Her yıl aynı şekilde tekrarlanan yarışmalar (belediye/yayınevi/dernek yarışmaları gibi) için
her yıl yeni bir post açmak yerine `_posts/evergreen/` klasöründe **tek bir sayfa** tutuyoruz.
Yeni dönem duyurulunca o dosya güncellenir, sabit kalır.

- Yarışmayı isme göre bulmak için: `_posts/evergreen/INDEX.md` (alfabetik liste, Jekyll bu
  dosyayı derlemez, sadece rehber amaçlıdır). Yeni bir evergreen sayfa eklediğinde bu dosyayı
  da güncelle.

### Var olan bir evergreen sayfayı yeni yıla güncellemek

1. Önce eski dönemin içeriğinin ayrıca arşivde olduğunu doğrula: evergreen dosyasının
   "Geçmiş Yıllar" bölümündeki en son linke bak, o linkin gittiği dosyada
   `archived_to: "/<evergreen-permalink>"` alanı olmalı. Yoksa üzerine yazmadan önce mevcut
   içeriği `_posts/<yıl>/<ay>/` altına ayrı bir dosya olarak kopyala ve o alanı ekle.
2. Evergreen dosyasında şu alanları yeni yılın bilgisiyle güncelle:
   - `date` (duyurunun yapıldığı gün)
   - `description`, `excerpt` (yeni ödül/tarih bilgisiyle)
   - `tags` (ay/yıl etiketini güncelle, `her yıl tekrarlanan` etiketini koru)
   - `lastDate` (yeni son başvuru tarihinin epoch/Unix timestamp karşılığı — bkz. aşağıdaki "Date" bölümü)
   - `dateHuman`, `price`, `comTopic`, `requirements`, `image` (varsa yeni bilgiyle)
   - **`permalink`'e dokunma** — sabit kalmalı, sitedeki tüm linkler ona göre çalışıyor
   - Gövde metnindeki katılım koşulları, ödüller, seçici kurul gibi bölümleri yeni bilgiyle güncelle
3. Dosyanın sonundaki "Geçmiş Yıllar" listesine, artık geçmiş olan yılın satırını en üste ekle.

### Yeni bir yarışmayı ilk kez evergreen'e çevirmek

1. En güncel (son) yıla ait duyuru dosyasını `_posts/evergreen/` altına taşı
   (`git mv ...`), dosya adını `<tarih>-<temiz-slug>.md` şeklinde ver.
2. Başlıktan/alt başlıklardan sıra numarasını veya yılı kaldır (örn. "5. Filan Yarışması" →
   "Filan Yarışması"), o yıla özgü talimatları (e-posta konu başlığı gibi) olduğu gibi bırak.
3. `date` alanını ekle, `tags` listesine `her yıl tekrarlanan` ekle.
4. `permalink` için: eski yazılardan biri zaten temiz (yılsız) bir permalink kullanıyorsa onu
   evergreen sayfaya devret (o eski yazının permalink'ini `-<yıl>` ekleyerek değiştir); hiçbiri
   kullanmıyorsa yeni bir stabil slug seç.
5. Eski tüm yılların yazılarına `archived_to: "/<yeni-evergreen-permalink>"` ekle (permalink'lerine
   dokunma, sadece bu alanı ekle).
6. Evergreen sayfanın sonuna "Geçmiş Yıllar" bölümü ekleyip eski yılların linklerini
   (yeniden eskiye) sırala.
7. `_posts/evergreen/INDEX.md`'ye yeni yarışmayı alfabetik yerine ekle.
8. Tüm dosyalardaki `permalink` alanlarını `grep` ile kontrol edip çakışma olmadığından emin ol.

## Zayıf / Güncelliğini Yitirmiş İçerik

Bir yarışma tamamen değişmiş (farklı bir programa dönüşmüş, bir daha düzenlenmemiş vb.) ve
güncellemeye değmiyorsa ama sayfayı silmek istemiyorsanız (eski link/bookmark kırılmasın diye),
front matter'a `noindex: true` ekleyin — sayfa sitede kalır ama arama motorlarına indekslenmez.

İçeriğin hiçbir değeri kalmadıysa (ör. tamamen başka bir formata dönüşmüş, güncel bir karşılığı
da yazılmayacaksa) dosyayı `git rm` ile silin; GitHub Pages statik olduğu için gerçek bir 410
status kodu veremiyoruz, silinen sayfa doğal olarak 404 döner — Google bunu 410'a yakın şekilde
değerlendirip zamanla indeksten düşürür. `robots.txt` ile engellemeyin, o zaman Google `noindex`
etiketini bile göremez.

## Date  
- https://jsbin.com/yodinefodu/edit?js,console
- console.log(new Date(2022,4,9).getTime()/1000)

## Add Google Calendar
https://calendar.google.com/calendar/u/1?cid=ZWRlYml5YXQueWFyaXNtYWxhcmlAZ21haWwuY29t
