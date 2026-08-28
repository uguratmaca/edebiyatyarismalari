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
permalink: "15-abdullah-duran-oyku-yarismasi"
image: "https://edebiyatyarismalari.com/images/2026/temmuz/15-abdullah-duran-oyku-yarismasi.webp"
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
`sticky` ile karıştırma, o ayrı bir alan ve ana sayfa sabitlemesi için).

`totalPrize` yoksa post, `money.html` layout'unun kullandığı "para ödüllü
yarışmalar" listesine girmez — parasal ödül yoksa alanı boş bırak, uydurma.

`comTopic` yoksa (yarışmanın belirli bir konu şartı yoksa) alanı boş
bırakmak/atlamak yerine `"Serbest"` yaz.

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
`her yıl tekrarlanan` de eklenir — alt klasöre göre tür soneki alır:
`_posts/evergreen/hikaye/` → `her yıl tekrarlanan hikaye`, `siir/` → `her yıl tekrarlanan şiir`,
`roman/` → `her yıl tekrarlanan roman`, `diger/` (tek bir türe girmeyen veya birden fazla
türü kapsayan yarışmalar) → sonek olmadan sade `her yıl tekrarlanan`. Evergreen'e taşıma sürecinin tamamı
(hangi alt klasöre gideceği, `archived_to`, "Geçmiş Yıllar" bölümü vb.) için
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
