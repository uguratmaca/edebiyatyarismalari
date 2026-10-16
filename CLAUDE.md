# edebiyatyarismalari.com

Jekyll sitesi. Yarışma duyuruları `_posts/<yıl>/<ay>/` altında, klasör postun **eklendiği** yıl/ay'a göre belirlenir (görseller de aynı şekilde `images/<yıl>/<ay>/`).

Yeni yarışma postu eklerken front matter alanları, `tags` filtre kategorileri ve görsel
işleme (resize/watermark) için `.claude/notes-post-schema.md`'ye bak.

## Genel kurallar (detayı `.claude/notes-post-schema.md`'de)

- **Hiçbir URL 404 olmasın.** Permalink değişince dosyayı yeniden adlandırma, `archived_to`/`redirect_from` kullan, sonra `scripts/find_lost_urls.rb` ile doğrula.
- **İç linklerde ve `archived_to`'da sonda `/` yok** (`/slug`, `/slug/` değil). Sayfalar `slug.html` olarak yayınlandığından slash'lı adres 404 verir ve canonical bozulur.
- **Permalink'te edisyon numarası yok** (`...-oyku-yarismasi`, `...-2-oyku-yarismasi` değil); yarışma ileride evergreen olacakmış gibi adlandırılır.
- **Yarışma sonucu gelince yeni post açma**, mevcut permalink'i (evergreen ise o yılın arşiv kopyasını) güncelle.
- **Yeni postta kilit nokta alanlarını doldur** (`workLimit`, `workCount`, `ageRange`, `typicalAgeRange`, `resultDate`, `keyPoints`, `submissionType`, `authorCondition`, `entryFee`): sadece şartnamede yazanlar, tam şartname metni kısaltılmadan korunur.
- **Repo public.** Commit edilen dosyalara (CLAUDE.md, README, `.claude/notes-post-schema.md`, kod yorumları, postlar) iç strateji, rakip analizi, gelir/abone gibi dışarıya açık olmaması gereken bilgi yazılmaz. Bu tür notlar git'e girmeyen `.claude/notes-*.md` dosyalarına (bkz. `.gitignore`) yazılır. Commit öncesi yeni/değişen dosyalar bu gözle kontrol edilir.
- **Her görünüm değişikliğinden sonra telefonda taşma kontrolü:** `bundle exec jekyll build`, sonra `python scripts/mobile_check.py` (Playwright, iPhone 13 / 390 px ve 360 px). Sayfa ekrandan genişse (yana kayıyorsa) hata verir ve taşan öğeleri listeler; hepsi "tamam" olmadan commit etme. Varsayılan sayfalar ana sayfa, bir yarışma, filtre, kategori, tekrarlanan yarışmalar ve 404; değişen sayfayı argüman olarak da ver. Düz bir headless tarayıcıyla `--window-size` daha geniş çizer, ona güvenme. Masaüstünde de 992-1439 px aralığına bak (menü orada sığmayabilir).
- **Metinlerde em dash (—) kullanma** (post, sayfa, front matter, kod yorumu). Nokta, virgül, parantez veya iki nokta kullan.

## Sosyal medya feed'i

`scripts/social_feed.py` Pages build'inde (`.github/workflows/jekyll.yml`, push'ta ve her gün) `_site/social.json`'u ve listelenen yarışmaların `<görsel>-social.jpg` kopyalarını (1080x1350, afiş kırpılmadan, bulanık arka plan) ile haftalık listenin kartını (`images/social/haftalik-<yıl>-W<hafta>.jpg`) üretir; bunlar commit edilmez. Sosyal medya hesaplarına otomatik paylaşım bu feed'den yapılır: yeni yarışma, son başvurudan 1 hafta önce hatırlatma, pazartesi o haftanın kapanan yarışmaları. `hidden: true` postlar paylaşılmaz. Paylaşım metni `title`, `description`, `dateHuman` ve `totalPrize`'dan, hashtag'ler "... yarışması" ile biten tag'lerden gelir; bu yüzden bu alanlar paylaşılabilir durumda tutulur.

Her öğenin `people` alanı düzenleyen kurumu (`organizer`) ve jüriyi (`## ... Jürisi` başlığı altındaki maddeler, unvansız ad) adıyla verir; Instagram paylaşımında bunların hesapları etiketlenir. **Instagram hesapları bu repoya yazılmaz**: ad ile hesap eşleşmesi paylaşımı yapan, kardeş klasördeki özel `social-poster` reposunun `data/instagram/edebiyat.yml` dosyasında tutulur. Yeni yarışma eklerken:
- Düzenleyen kurumun ve jüri üyelerinin Instagram hesaplarını ara. Hesapları social-poster'da `python -m poster.ig_lookup <kullanıcı adları>` ile doğrula (ad, takipçi, bio; kişisel hesaplar "not found" döner); kişisel jüri hesaplarını kullanıcıya onaylat. Yanlış etiket hiç etiketten kötüdür.
- Bulunanları ve aranıp bulunamayanları (`null`, bir daha aranmasın diye) o dosyaya ekle, social-poster'da commit et; bulamadıklarını kullanıcıya sor.
- Eşleşme ada göre: dosyada zaten olan bir ad yeni yarışmanın jürisinde geçiyorsa aynı kişi mi bak (unvan, şehir, hesabın bio'su). Emin değilsen kullanıcıya sor; başka biriyse o yarışmanın postunda adı ayırt edecek biçimde yaz (ör. ikinci adıyla) ki yanlış kişi etiketlenmesin.
- Jüri adlarını `## {title} Jürisi` altında `- Ad Soyad (unvan) – rol` biçiminde yaz; ad bu satırdan ayıklanır.

## Öncelik: SEO ve GEO

Bu proje için her zaman öncelik **SEO**'dur. Tasarım, UX, performans gibi konularda karar verirken de bu önceliği göz önünde bulundur (ör. semantic HTML, başlık hiyerarşisi, alt text, sayfa hızı, crawl edilebilirlik, structured data gibi etkenler tercih sebebidir).

**GEO** (Generative Engine Optimization — ChatGPT, Perplexity, Google AI Overviews, Claude gibi yapay zekâ motorları tarafından keşfedilmek/atıf almak) de SEO kadar önemli bir önceliktir. Kullanıcılar artık "şu an açık öykü yarışmaları neler" gibi soruları arama motoru yerine bir AI'a soruyor; sitenin bu tür yanıtlarda kaynak gösterilmesi de SEO kadar değerli. Kararlarda bunu da göz önünde bulundur: içeriğin AI tarafından kolayca çıkarılabilir/alıntılanabilir olması (net, etiketli gerçekler; belirsiz olmayan tek-konu sayfalar), yapılandırılmış veri (schema.org), ve AI crawler'ların engellenmemesi gibi etkenler tercih sebebidir.

## Front matter `tags` kuralları

- Ay/yıl etiketi (ör. `ekim 2026`) postun eklendiği ayı değil, yarışmanın **son başvuru tarihinin** (dateHuman/lastDate) ay ve yılını gösterir.
- Öykü/hikaye yarışmaları için genel tag her zaman **"hikaye yarışması"** olmalı, "öykü yarışması" değil. ("minimal öykü yarışması", "küçürek öykü yarışması" gibi daha spesifik alt-kategori tag'leri bu kuraldan etkilenmez.)

## `lastDate` hesaplama

`lastDate`, son başvuru tarihinin (dateHuman) İstanbul saatiyle gece yarısı (00:00) karşılığının Unix epoch'udur — yani `dateHuman` gününden bir gün önce, saat 21:00 UTC.

## Değerlendirilecek: eski/bitmiş postlarda noindex

Sitede binlerce (2018'den beri ~2000) yarışma duyurusu var; çoğu tek seferlik ve bir daha tekrarlanmayan, bitmiş yarışmalar. Şu an hepsi `index, follow` — hiçbirine `noindex` uygulanmıyor.

Bu bilinçli olarak ertelendi (2026-07 tarihli SEO incelemesinde gündeme geldi): eski postlara noindex eklemek sitenin "güncel/aktif" sinyalini güçlendirebilir, ama bazı eski sayfalar backlink/referans değeri taşıyabilir ve noindex bunu siler. Binlerce dosyayı tek tek "gerçekten tekrarlanmıyor mu" diye evergreen sistemle karşılaştırmak da hata payı yüksek, zaman alıcı bir iş.

Karar: Şimdilik dokunulmuyor. İleride ele alınırsa, önce hangi postların gerçekten hiç tekrarlanmadığını (evergreen/"her yıl tekrarlanan" sistemine dahil olmayanları) belirleyecek bir kritere ihtiyaç var.
