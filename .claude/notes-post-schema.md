# Yeni yarışma postu ekleme şeması

CLAUDE.md ve README.md'de olmayan, front matter alanları ve görsel işleme
konusundaki kurallar burada. Genel kurallar (klasör yapısı, SEO önceliği,
tags ay/yıl kuralı, `lastDate` hesaplama, evergreen sistemi) için CLAUDE.md
ve README.md'ye bak.

## Front matter alanları

```yaml
---
layout: post
title: "15. Abdullah Duran Öykü Yarışması"
description: "Kısa, tek cümlelik SEO açıklaması (meta description + og/twitter)."
category: articles          # her zaman sabit "articles"
tags: [aralık 2026, hikaye yarışması, genel]
lastDate: 1798664400        # bkz. CLAUDE.md "lastDate hesaplama"
dateHuman: "31 Aralık 2026" # son başvuru tarihi, insan-okur formatı
comTopic: "Serbest"         # yarışmanın konusu
totalPrize: "60 Bin TL'dir" # toplam para ödülü (sadece parasal ödül varsa doldur)
attendance: "E-Posta"       # gönderim şekli, serbest metin (bkz. aşağıdaki normalizasyon)
organizer: "Eğitim Sen Amed Şubeleri"
requirements: "Öykü alanında üretim yapan herkes katılabilir."
permalink: "abdullah-duran-oyku-yarismasi"   # edisyon numarası (15.) permalink'e girmez, bkz. "Permalink ve URL kuralları"
image: "https://edebiyatyarismalari.com/images/2026/temmuz/abdullah-duran-oyku-yarismasi.webp"
excerpt: "Kısa özet, <strong> ile öne çıkan kısım vurgulanabilir."
---
```

Nadiren kullanılan ek alanlar: `imageAlt` (görsel `alt`i özelleştirmek için,
yoksa `"{title} duyuru görseli"` kullanılır), `author`/`authorUrl` (varsayılan
"Uğur Atmaca"), `archived_to` (sadece evergreen arşiv kopyalarında —
bkz. README.md), `redirect_from` (eski URL'den yönlendirme), `noindex: true`
(bkz. CLAUDE.md "eski/bitmiş postlarda noindex" — şu an bilinçli olarak
kullanılmıyor), `featured: true` (haftalık Mailchimp RSS-otomasyonunun
kaynağı olan `feed.xml`'de postu en üste çıkarır — bkz. `_plugins/feed_order.rb`;
`sticky` ile karıştırma, o ayrı bir alan ve ana sayfa sabitlemesi için),
`hidden: true` (postu ana sayfa listelemesinden — `index.html`/`sayfa2..5` —
düşürür, bkz. `_plugins/homepage_pagination_generator.rb`; site edebiyat
yarışmaları odaklı olduğu için resim/fotoğraf/tasarım/karikatür/beste/kısa film
gibi **edebiyat dışı** yarışmalarda kullanılır — post yine de kendi URL'sinden,
tag filtresinden ve aramadan erişilebilir kalır, sadece ana sayfada öne
çıkmaz. Bir yarışma hem edebiyat hem edebiyat-dışı kategoriler içeriyorsa
(ör. bir festivalin hem senaryo hem kısa film dalı varsa), Akbank Kısa Film
Festivali örneğindeki gibi **ikiye böl**: edebiyat kategorisi (senaryo vb.)
ayrı, görünür bir post/evergreen sayfa olsun; edebiyat dışı kategori (kısa
film vb.) ayrı, `hidden: true` bir post/evergreen sayfa olsun — bkz.
`akbank-kisa-film-festivali-senaryo-yarismasi` (görünür) ve
`akbank-kisa-film-festivali` (hidden, artık güncellenmiyor) örneği).

`totalPrize` yoksa post, `money.html` layout'unun kullandığı "para ödüllü
yarışmalar" listesine girmez — parasal ödül yoksa alanı boş bırak, uydurma.

`comTopic` yoksa (yarışmanın belirli bir konu şartı yoksa) alanı boş
bırakmak/atlamak yerine `"Serbest"` yaz.

## Permalink ve URL kuralları

- **Permalink'te edisyon/sıra numarası ("1.", "2." vb.) olmaz.** İlk kez düzenlenen bir
  yarışma bile, ileride tekrarlanıp evergreen'e dönüşecekmiş gibi verilir
  (`tahta-gemi-uluslararasi-oyku-yarismasi`, `tahta-gemi-uluslararasi-1-oyku-yarismasi` değil).
  Sayı içeren permalink sonraki yıl farklı bir URL gerektirir ve link/SEO değeri bölünür.
  Başlıkta (`title`) numara kalabilir, kural sadece permalink/slug ve görsel adı içindir.
- **İç linklerde ve `archived_to` değerinde sonda `/` yazılmaz.** Normal post permalink'leri
  `slug.html` olarak yayınlanıyor: sayfa `/slug` adresinde 200 verir, `/slug/` ise çoğu zaman 404.
  `archived_to` canonical etiketini de ürettiği için slash'lı yazılırsa canonical 404'e işaret eder.
  Bu yüzden "Geçmiş Yıllar" listelerinde `(/slug)`, front matter'da `archived_to: "/slug"` yaz.
  İstisna: `menuler/` altındaki dizin tarzı sayfalar (`/hikaye-yarismalari/`, aylık listeler vb.)
  slash'lı da çalışır, onlara dokunma. Emin değilsen hedefi hem slash'lı hem slash'sız `curl` ile dene.
- **Hiçbir URL 404'e düşmemeli.** Site 2018'den beri yayında, ~2000 duyuru var.
  - Permalink değişiyorsa (özellikle evergreen dönüşümünde) dosyayı `git mv` ile yeniden
    adlandırma. Yeni evergreen dosyası oluştur, eski dosyaları yerinde bırakıp `archived_to` ekle.
  - Permalink gerçekten değişecekse `redirect_from` ekle (`jekyll-redirect-from` kurulu).
  - Evergreen dönüşümü veya permalink değişikliğinden sonra
    `bundle exec ruby scripts/find_lost_urls.rb` çalıştırıp yeni kayıp URL çıkmadığını doğrula.
    Script'in raporladığı her adayı gerçekten araştır, "muhtemelen eski/alakasız" deyip geçme.
  - Toplu dönüşümler için `scripts/convert_to_evergreen.rb` var (varsayılan dry-run, `--apply`
    ile yazar), elle yaparken de aynı deseni izle.

## Yarışma sonucu duyurulunca

Kazananlar/sonuç geldiğinde **yeni post/permalink açma**, mevcut permalink'e "Sonuçlar" veya
"Kazananlar" bölümü ekleyerek yerinde güncelle. "X yarışması" araması zaten o permalink'te
sıralama ve backlink biriktirmiş, "X yarışması sonuçları" niyeti de büyük ölçüde aynı sayfada
karşılanır. Ayrı permalink link otoritesini böler ve arşivi gereksiz büyütür.

- Evergreen yarışmaysa (`_posts/evergreen/` altında, `her yıl tekrarlanan` tag'li) sonucu
  evergreen sayfaya değil, o yılın **arşivlenmiş kopyasına** (`_posts/<yıl>/<ay>/...`,
  `archived_to` alanı olan dosya) ekle. Evergreen sayfa bir sonraki dönemin duyurusunu temsil eder.
- Evergreen değilse yarışmanın kendi postunu güncelle.
- İstisna: sonuç haberi kendi başına büyük arama hacmi olan prestijli bir ödülse ayrı post
  ve duyurudan link düşünülebilir, ama varsayılan davranış yukarıdaki.

## Başka kaynaklarda bulunan yarışmayı siteye eklerken

Yarışma bir haber/toplayıcı sitede, sosyal medyada vb. bulunup bizde karşılığı yoksa:

1. **Son başvuru tarihi geçmişse "yeni/aktif" gibi gösterme.** Gövde "başvurular sürüyor/açıldı"
   diliyle değil geçmiş bir kayıt gibi yazılır, `date:` alanı bugüne çekilip ana sayfada/RSS'te
   taze bir duyuru gibi öne çıkarılmaz.
2. **Tekrarlayan bir yarışmaysa evergreen yapıyı uygula** (`_posts/evergreen/<tür>/`,
   "her yıl tekrarlanan ..." tag'i, bilinen geçmiş edisyonlar için "Geçmiş Yıllar" bölümü).
3. **Edebiyat dışı veya karma yarışmalarda `hidden` kuralını uygula** (yukarıya bak).
4. **Kaynak olarak yarışmayı düzenleyen kurumun kendi sitesi/sosyal medyası gösterilir.**
   Bilgiyi bulduğun haber veya toplayıcı site post gövdesinde ve `organizer` alanında anılmaz.
5. Ekleme bitince yukarıdaki URL kurallarını ve `find_lost_urls.rb` kontrolünü uygula.

## `tags` için sabit kategori listeleri

`tags` serbest olsa da, `menuler/ozel/yarisma-filtrele.md` içindeki filtre
iki sabit liste kullanıyor — yeni post eklerken tag'lerden en az biri bu
listelerden olmalı ki filtrede görünsün:

- **Tür** (`type`): hikaye yarışması, şiir yarışması, roman yarışması, deneme
  yarışması, makale yarışması, resim yarışması, fotoğraf yarışması, kısa film
  yarışması, kompozisyon yarışması, tasarım yarışması, karikatür yarışması,
  mektup yarışması, senaryo yarışması, tiyatro oyunu yazma yarışması, masal
  yarışması, proje yarışması, afiş yarışması, beste yarışması, anı yarışması,
  kitap dosyası, kitap okuma yarışması
- **Kitle** (`audience`): genel, ilkokul, ortaokul, lise, üniversite, kadın,
  öğretmen

Buna ek olarak ay/yıl tag'i (CLAUDE.md kuralı) ekleniyor. Evergreen postlarda
`her yıl tekrarlanan` de eklenir; **sadece** `_posts/evergreen/hikaye/`, `siir/`, `roman/`
alt klasörlerine giden postlar tür soneki alır (`her yıl tekrarlanan hikaye`, `...şiir`,
`...roman`) çünkü bunların `/her-yil-tekrarlanan-oyku-yarismalari/` gibi kendi özel menü
sayfaları var (`menuler/ozel/her-yil-tekrarlanan-*.md`, `_layouts/monthly.html`'de
`post.tags contains page.key` ile **tam string** eşleşmesi yapıyor; soneksiz/sonekli tag'ler
birbirinin yerine geçmez). `senaryo/`, `kisa-film/` ve `diger/` (tek bir türe girmeyen veya
birden fazla türü kapsayan yarışmalar) alt klasörlerine giden postlarda sonek olmadan sade
`her yıl tekrarlanan` kullanılır; bu türler için zaten `menuler/diger/senaryo-yarismalari.md`
(`/senaryo-yarismalari/`) ve `menuler/diger/kisa-film-yarismasi.md` (`/kisa-film-yarismalari/`)
gibi genel (evergreen'e özel olmayan) kategori sayfaları olduğundan ayrıca bir
`her-yil-tekrarlanan-senaryo/kisa-film` sayfası **açılmaz**; mevcut kategori sayfasıyla
neredeyse birebir çakışan, ince içerikli bir sayfa üretir. Evergreen'e taşıma sürecinin
tamamı (hangi alt klasöre gideceği, `archived_to`, "Geçmiş Yıllar" bölümü vb.) için
README.md'deki "Evergreen (her yıl tekrarlanan yarışmalar)" bölümüne bak.

## `attendance` serbest metin ama normalize ediliyor

`_plugins/attendance_normalizer.rb` (build-time) ve `js/yarisma-filtrele.js`
(client-side, aynı regex'in JS kopyası) `attendance` alanını regex ile şu
sabit kovalara eşliyor: **E-posta**, **Online/Web Sitesi**, **Kargo/Posta**,
**Elden**, **Okul/Kurum**, **Sosyal Medya**, (eşleşmezse **Diğer**). Serbest
yazılabilir ama anahtar kelimeler (`e-posta`/`mail`, `web sitesi`/`online`,
`kargo`/`posta`, `elden`/`şahsen`/`yüz yüze`, `okul`/`müdürlük`/`kurum`,
`instagram`/`whatsapp`/... ) geçmeli ki doğru kovaya düşsün. Örn. "yüz yüze"
katılım için `attendance` metninde "elden" veya "yüz yüze" geçmeli — sadece
"Yüzyüze" yazmak da regex'i (`yüz ?yüze`) eşler, sorun yok.

## Görsel işleme

Kullanıcı görseli genelde kendisi sağlıyor (Instagram, kurum web sitesi vb.
kaynaklardan) — genelde jpeg/png. Post eklenirken görsel de `images/<yıl>/<ay>/`
altına eklenir; işlenmemiş haliyle bırakılmaz:

1. `scripts/process_image.py` ile sağ-alt köşeye yarı saydam
   "edebiyatyarismalari.com" filigran rozeti eklenir, WebP olarak (kalite 82,
   iyi sıkıştırma/performans dengesi) kaydedilir:

   ```
   "/c/Python311/python.exe" scripts/process_image.py <girdi.jpg> images/<yıl>/<ay>/<slug>.webp
   ```

   Filigranın amacı: görseli kopyalayan başka siteler dolaylı olarak
   edebiyatyarismalari.com'a atıf yapmış olur.

   **Boyutu 1200x630'a zorlamaya gerek yok.** `og:image`/schema ImageObject
   meta'ları bu boyutu sabit beyan etse de, sayfadaki gerçek görüntüleme
   `css/theme.css`'teki `.hero-img { aspect-ratio: 1200/630; object-fit: contain; }`
   kuralıyla çözülüyor — dikey (Instagram story, 1440x1920) veya kare
   (1080x1080) kaynak görseller de sayfada düzgün görünür, kırpılmaz. Script
   varsayılan olarak orijinal boyutu korur; gerçekten hard-crop gerekiyorsa
   `--resize` bayrağı var.
2. Front matter `image:` alanına tam URL (`https://edebiyatyarismalari.com/images/...`) yazılır.
3. WebP standart format — avif de teknik olarak destekleniyor (script
   `--no-watermark` dışında format seçeneği sunmuyor, gerekirse script'e
   `.avif` çıktı desteği eklenebilir) ama şu an tutarlılık için webp tercih
   ediliyor.

Script Pillow (`pip show pillow` ile kurulu, sistem Python'ı `C:\Python311\python.exe`)
kullanıyor; `python3` PATH'te Microsoft Store alias'ına takılıyor, tam yol
gerekiyor.

## Post gövdesi (body) şablonu

Front matter'dan sonra body şu bölümlerden oluşur (sırayla, gereksiz olanlar atlanır):

```markdown
## {title}

{Kurumu ve yarışmayı tanıtan 1-3 paragraf. İlk paragrafta yarışma adı
**kalın** yazılır. Varsa yarışmanın arka planı/amacı, kaçıncı kez
düzenlendiği gibi bilgiler burada.}

Katılım Koşulları:
- {Kimler katılabilir (yaş, meslek, vb. şart varsa)}
- {Dil, tür, konu (comTopic) şartı}
- {Kelime/sayfa/karakter limiti, font, punto gibi biçim şartları}
- {Daha önce ödül almamış/yayımlanmamış olma gibi özgünlük şartları}
- {Başvuru şekli — attendance ile tutarlı: e-posta adresi, online form, posta adresi vb.}
- {Son başvuru tarihi (dateHuman ile aynı) ve varsa saat}
- {Katılım ücreti (genelde "ücretsizdir")}

{`attendance` "Online"/"İnternet Sitesi"/"Web Sitesi" gibi bir değerse, katılım
koşulları listesindeki başvuru cümlesinde mutlaka gerçek başvuru URL'sine giden
bir markdown linki olmalı — sadece domain adını düz metin yazma:
`[doganyayinlari.com.tr/oyku-yarismasi](https://doganyayinlari.com.tr/oyku-yarismasi){:rel="nofollow"}{:target="_blank"}{:class="gtag"}`}

{Opsiyonel — başvuru ayrı, öne çıkan bir link/buton olarak da verilebilir:}
#### [Başvuru Formu](https://...){:rel="nofollow"}{:target="_blank"}{:class="gtag"}

## {title} Ödülleri

- Birincilik Ödülü: {tutar}
- İkincilik Ödülü: {tutar}
- Üçüncülük Ödülü: {tutar}

{Opsiyonel — mansiyon, sonuç açıklama tarihi, ödül töreni bilgisi.}

{Opsiyonel, sadece jüri varsa — bkz. aşağıdaki not:}
## {title} Jürisi

- {Ad Soyad} ({unvan/meslek}) – {varsa "Jüri Başkanı" gibi rol}
- {Ad Soyad} ({unvan/meslek})

{Opsiyonel kapanış paragrafı — yarışmanın anlamı/önemi üzerine.}
```

Jüri üyeleri her zaman ayrı `## {title} Jürisi` başlığı altında bullet
liste olur, cümle içine gömülmez.

Somut, tam bir örnek için `_posts/2026/temmuz/2026-07-22-2-rota-oyku-yarismasi.md`
dosyasına bakılabilir (jürili + başvuru formlu + ödül+mansiyon örneği).
