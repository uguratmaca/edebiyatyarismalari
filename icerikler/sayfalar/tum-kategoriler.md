---
layout: simple
headline: "Tüm Kategoriler"
title: "Tüm Edebiyat Yarışması Kategorileri | Edebiyat Yarışmaları"
permalink: "tum-kategoriler/"
description: "Şiir, hikaye, roman, senaryo, resim, fotoğraf ve daha birçok türde edebiyat yarışması kategorisine buradan ulaşabilirsiniz."
---

Aradığın kategori menüde yoksa buradan bulabilirsin. Yaş grubuna ve türe göre filtrelemek için [Yarışma Filtrele](/yarisma-filtrele/) sayfasına da bakabilirsin.

<style>
  .kategori-listesi { column-count: 1; column-gap: 2rem; }
  @media (min-width: 576px) { .kategori-listesi { column-count: 2; } }
  @media (min-width: 992px) { .kategori-listesi { column-count: 3; } }
  .kategori-listesi li { break-inside: avoid; }
</style>

<ul class="nav flex-column kategori-listesi">
{% capture raw %}{% for pair in site.data.pageList %}{{ pair[1].url }}::{{ pair[1].title }}|||{% endfor %}{% endcapture %}
{% assign categories = raw | split: "|||" | uniq | sort %}
{% for item in categories %}
{% assign parts = item | split: "::" %}
  <li class="nav-item"><a class="nav-link" href="{{ site.url }}/{{ parts[0] }}">{{ parts[1] }}</a></li>
{% endfor %}
</ul>
