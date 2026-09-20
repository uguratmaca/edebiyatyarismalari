# GSC 404 raporu - redirect işi

## GSC raporlarıyla çalışırken (genel kural)

Search Console'dan gelen bir CSV'yi (404, keşfedildi ama dizine eklenmedi, tarandı ama dizine
eklenmedi vb.) etkilenen URL'lerin **tam ve yetkili listesi** olarak kabul et, örnek değil.
CSV'deki URL'leri düzelt. Bir bulguyu ("bu sayfa ince içerik") repodaki aynı desendeki tüm
sayfalara genelleme ("hepsini düzeltelim"), repo genelinde grep ile daha fazla örnek çıksa bile.
Daha geniş bir denetim değerliyse bunu ayrı ve isteğe bağlı bir öneri olarak sun, mevcut işin
içine sessizce katma. Kullanıcı bir export verdiğinde listenin tam olup olmadığını teyit et.

## DURUM: Yapılacak #1 (redirect'ler) TAMAMLANDI

37 URL'ye (5 git-history + 31 prefix-matching + 1 evergreen-yönlendirme) redirect_from eklendi, `bundle exec jekyll build` hatasız geçti, üretilen redirect stub'ları (meta-refresh + JS + noindex) doğru çalışıyor.

- `simit-cay-` → tek bir evergreen sayfaya (`_posts/evergreen/diger/2026-06-23-simit-cay-etkinlikleri-siir-yarismasi.md`, permalink `simit-cay-etkinlikleri-siir-yarismasi`) yönlendirildi — bu, edisyon belirsizliğini evergreen sayfaya yönlendirerek çözdü.
- `anadolu-` ve `2020-` hâlâ bilerek atlandı: bunlar aynı yarışmanın farklı yılları değil, birbiriyle alakasız farklı yarışmalar aynı öneki paylaşıyor, birleştiren evergreen sayfa da yok.

Detaylar aşağıda korunuyor.

Sıradaki: **Yapılacak #2** (protokol eksik linkler) ve **Yapılacak #3** (legacy articles/ URL'leri) — henüz başlanmadı. Ayrıca değişiklikler henüz commit edilmedi.

---
(Aşağısı eski/orijinal plan notu, referans için duruyor)

Kaynak: Google Search Console "Page indexing - Not found (404)" raporu, 43 URL (bkz. sohbet geçmişi / kullanıcının verdiği CSV).

## Tamamlanan

1. `jekyll-redirect-from` gem'i eklendi ve kuruldu:
   - `Gemfile` → `gem 'jekyll-redirect-from'`
   - `_config.yml` → `plugins:` listesine `'jekyll-redirect-from'` eklendi
   - `bundle install` çalıştırıldı, gem kurulu ve aktif.
   - Kullanım: bir postun front matter'ına `redirect_from: [/eski-url/]` eklenince, plugin o eski path'te otomatik yönlendirme sayfası üretiyor.

2. Git geçmişinde eski permalink değeri net tespit edilebilen 5 URL'ye redirect eklendi:
   - `/İhsan-Yilmazsamli-Oyku-Yarismasi` → `_posts/2026/nisan/2026-04-17-ihsan-yilmaz-basli.md`
   - `/atilla-ilhan-siir-roman-yarismasi-2024` → `_posts/2024/mart/2024-03-17-atilla-ilhan-siir-roman-yarismasi-2024.md`
   - `/bafra-hikaye-yarismasi` → `_posts/2023/ocak/2023-01-21-bafra-hikaye-yarismasi.md`
   - `/articles/2020/03/01/canakkalezaferikompozisyonresimyarismasi.html` → `_posts/2020/mart/2020-03-01-canakkale-zaferi-kompozisyon-resim-yarismasi.md`
   - `/rifat-ilgaz-` → `_posts/2024/subat/2024-02-03-rifat-ilgaz-siir-yarismasi-2024.md` (git'te iz yok ama kullanıcı canlıda olduğunu doğruladı)

3. Redirect gerekmeyen (gerçekten silinmiş, karşılığı yok):
   - `/articles/2019/02/01/subat-diger-edebiyat-yarismalari.html` — tek seferlik 2019 "diğer yarışmalar" derleme postu, evergreen karşılığı yok.

4. Kapsam dışı bırakılan (ayrı sorunlar, bu redirect işinin parçası değil):
   - `/essaycompetition.tkbb.org.tr/?ref=...` ve `/www.odemis.bel.tr` → bunlar permalink değil, postlardaki linklerde `https://` eksikliğinden kaynaklanan ayrı bir bug (bkz. "Yapılacak #2" aşağıda).
   - `/images/2026/subat/6-oguz-atay-oyku-odulu.avif` → bu path hiç var olmamış, gerçek görsel `images/2026/mart/` altında. Redirect gerekmiyor.
   - `/3. İhsan YılmazŞamlı Öykü Yarışması` (boşluklu/başlık-gibi URL) → template'lerde böyle üretilmiyor, muhtemelen dış kaynaklı hatalı link. Aksiyon gerekmiyor.

## Önemli bulgu (metodoloji notu)

Trailing-hyphen'li slug'lar (örn. `/rifat-ilgaz-`, `/kadin-haklari-`) muhtemelen kullanıcının permalink'i eksik yazıp canlıya alması, sonra düzeltmesinden kaynaklanıyor — ANCAK bu düzeltme ilk commit'ten önce oluyor, o yüzden git geçmişinde İZ YOK. Git-history yöntemi bu kalan URL'ler için işe yaramıyor.

**Bir sonraki oturumda kullanılacak yöntem:** git'e bakmadan, mevcut canlı postların `permalink:` alanlarıyla ÖNEK eşleştirmesi yap (prefix match):
- Tek aday varsa → kesin eşleşme, redirect ekle.
- Birden fazla aday varsa (aynı konu farklı yıl/edisyon) → CSV'deki "Last crawled" tarihine göre en yakın edisyonu seç (aşağıdaki tabloda tarihler var). Yanlış edisyon seçilse bile ziyaretçi 404 yerine aynı konudaki ilgili bir sayfaya düşer, düşük risk.
- Hiç aday yoksa → çözümsüz bırak, zorlama.

## Yapılmayı bekleyen 34 URL (Last crawled tarihiyle)

| URL slug | Last crawled |
|---|---|
| /anne-siirleri-siir- | 2026-05-02 |
| /2-interaktif-hikaye- | 2026-04-28 |
| /2-ganesa-mitolojik- | 2026-04-25 |
| /karanlik-oykuler- | 2026-04-10 |
| /ziynet-sertel- | 2026-04-07 |
| /kadin-haklari- | 2026-03-03 |
| /enver-gokce-siir- | 2026-03-03 |
| /yol-akademi- | 2026-03-01 |
| /mavera-edebiyat- | 2026-02-24 |
| /2-adi- | 2026-02-21 |
| /koklerden-gelecege- | 2026-02-18 |
| /zeynep-cemali-oyku | 2026-02-14 |
| /kirmizi-kalem- | 2026-02-07 |
| /myrina-yayinlari- | 2026-02-07 |
| /19-metin-altiok-siir- | 2026-02-07 |
| /24-tudem-edebiyat- | 2026-02-06 |
| /antakyanin-nefesi- | 2026-02-06 |
| /ganesa-mitolojik- | 2026-02-02 |
| /mahal-edebiyat- | 2026-02-02 |
| /mevlana-idris-siir- | 2026-01-26 |
| /goc-ve- | 2026-01-19 |
| /anadolu- | 2026-01-19 |
| /simit-cay- | 2026-01-19 |
| /fisek- | 2026-01-19 |
| /nakiyye- | 2026-01-19 |
| /haydi-sen- | 2026-01-19 |
| /2020- | 2026-01-19 |
| /1-sait-faik | 2026-01-19 |
| /guncelle- | 2026-01-19 |
| /ahmet-hamdi- | 2026-01-17 |
| /dr-kamil-furtun-oyku | 2026-01-17 |
| /dede-korkut-oyku- | 2026-01-12 |
| /hasan-ozkilic-oyku- | 2026-01-09 |
| /14-subat-polisiye- | 2026-01-09 |

Not: `/2-ganesa-mitolojik-` ve `/ganesa-mitolojik-` iki ayrı satır — "2-" önekli olan muhtemelen o yarışmanın 2. edisyonuna özel, ayrı ele alınmalı.

## Sıradaki adımlar (yarın)

1. Yukarıdaki 34 URL için önek eşleştirmesini yap, redirect_from ekle.
2. `bundle exec jekyll build` ile yerel test (site büyük olduğu için süre alabilir).
3. **Yapılacak #2:** `_posts/2023/mayis/2023-05-06-tkbb-makale-yarismasi.md:41` ve `_posts/2022/mayis/2022-05-27-odemis-belediyesi-siir-ve-oyku-yarismasi.md:23` dosyalarındaki linklere `https://` ekle (protokol eksikliği bug'ı).
4. **Yapılacak #3:** Legacy `articles/YYYY/MM/DD/*.html` URL'leri için genel bir değerlendirme (çoğu muhtemelen gerçekten silinmiş, tek tek kontrol gerekebilir).

## Değiştirilen dosyalar (henüz commit edilmedi)
- `Gemfile`
- `_config.yml`
- 5 post dosyası (yukarıda listeli)
- `Gemfile.lock` (bundle install sonrası güncellendi)
