# edebiyatyarismalari.com

Jekyll sitesi. Yarışma duyuruları `_posts/<yıl>/<ay>/` altında, klasör postun **eklendiği** yıl/ay'a göre belirlenir (görseller de aynı şekilde `images/<yıl>/<ay>/`).

Yeni yarışma postu eklerken front matter alanları, `tags` filtre kategorileri ve görsel
işleme (resize/watermark) için `.claude/notes-post-schema.md`'ye bak.

## Genel kurallar (detayı `.claude/notes-post-schema.md`'de)

- **Hiçbir URL 404 olmasın.** Permalink değişince dosyayı yeniden adlandırma, `archived_to`/`redirect_from` kullan, sonra `scripts/find_lost_urls.rb` ile doğrula.
- **İç linklerde ve `archived_to`'da sonda `/` yok** (`/slug`, `/slug/` değil). Sayfalar `slug.html` olarak yayınlandığından slash'lı adres 404 verir ve canonical bozulur.
- **Permalink'te edisyon numarası yok** (`...-oyku-yarismasi`, `...-2-oyku-yarismasi` değil); yarışma ileride evergreen olacakmış gibi adlandırılır.
- **Yarışma sonucu gelince yeni post açma**, mevcut permalink'i (evergreen ise o yılın arşiv kopyasını) güncelle.
- **Metinlerde em dash (—) kullanma** (post, sayfa, front matter, kod yorumu). Nokta, virgül, parantez veya iki nokta kullan.

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
