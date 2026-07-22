# edebiyatyarismalari.com

Jekyll sitesi. Yarışma duyuruları `_posts/<yıl>/<ay>/` altında, klasör postun **eklendiği** yıl/ay'a göre belirlenir (görseller de aynı şekilde `images/<yıl>/<ay>/`).

Yeni yarışma postu eklerken front matter alanları, `tags` filtre kategorileri ve görsel
işleme (resize/watermark) için `.claude/notes-post-schema.md`'ye bak.

## Öncelik: SEO

Bu proje için her zaman öncelik **SEO**'dur. Tasarım, UX, performans gibi konularda karar verirken de bu önceliği göz önünde bulundur (ör. semantic HTML, başlık hiyerarşisi, alt text, sayfa hızı, crawl edilebilirlik, structured data gibi etkenler tercih sebebidir).

## Front matter `tags` kuralları

- Ay/yıl etiketi (ör. `ekim 2026`) postun eklendiği ayı değil, yarışmanın **son başvuru tarihinin** (dateHuman/lastDate) ay ve yılını gösterir.
- Öykü/hikaye yarışmaları için genel tag her zaman **"hikaye yarışması"** olmalı, "öykü yarışması" değil. ("minimal öykü yarışması", "küçürek öykü yarışması" gibi daha spesifik alt-kategori tag'leri bu kuraldan etkilenmez.)

## `lastDate` hesaplama

`lastDate`, son başvuru tarihinin (dateHuman) İstanbul saatiyle gece yarısı (00:00) karşılığının Unix epoch'udur — yani `dateHuman` gününden bir gün önce, saat 21:00 UTC.

## Değerlendirilecek: eski/bitmiş postlarda noindex

Sitede binlerce (2018'den beri ~2000) yarışma duyurusu var; çoğu tek seferlik ve bir daha tekrarlanmayan, bitmiş yarışmalar. Şu an hepsi `index, follow` — hiçbirine `noindex` uygulanmıyor.

Bu bilinçli olarak ertelendi (2026-07 tarihli SEO incelemesinde gündeme geldi): eski postlara noindex eklemek sitenin "güncel/aktif" sinyalini güçlendirebilir, ama bazı eski sayfalar backlink/referans değeri taşıyabilir ve noindex bunu siler. Binlerce dosyayı tek tek "gerçekten tekrarlanmıyor mu" diye evergreen sistemle karşılaştırmak da hata payı yüksek, zaman alıcı bir iş.

Karar: Şimdilik dokunulmuyor. İleride ele alınırsa, önce hangi postların gerçekten hiç tekrarlanmadığını (evergreen/"her yıl tekrarlanan" sistemine dahil olmayanları) belirleyecek bir kritere ihtiyaç var.
