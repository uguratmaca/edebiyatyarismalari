# edebiyatyarismalari.com

Jekyll sitesi. Yarışma duyuruları `_posts/<yıl>/<ay>/` altında, klasör postun **eklendiği** yıl/ay'a göre belirlenir (görseller de aynı şekilde `images/<yıl>/<ay>/`).

## Front matter `tags` kuralları

- Ay/yıl etiketi (ör. `ekim 2026`) postun eklendiği ayı değil, yarışmanın **son başvuru tarihinin** (dateHuman/lastDate) ay ve yılını gösterir.
- Öykü/hikaye yarışmaları için genel tag her zaman **"hikaye yarışması"** olmalı, "öykü yarışması" değil. ("minimal öykü yarışması", "küçürek öykü yarışması" gibi daha spesifik alt-kategori tag'leri bu kuraldan etkilenmez.)

## `lastDate` hesaplama

`lastDate`, son başvuru tarihinin (dateHuman) İstanbul saatiyle gece yarısı (00:00) karşılığının Unix epoch'udur — yani `dateHuman` gününden bir gün önce, saat 21:00 UTC.
