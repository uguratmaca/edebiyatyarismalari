---
layout: default
title: "Yarışma Filtrele | Sana Uygun Edebiyat Yarışmasını Bul"
description: "Yarışma türüne, yaşına, başvuru şekline ve kitap durumuna göre güncel edebiyat yarışmalarını filtreleyin, tercihlerinizi kaydedip size özel listeyi her gelişinizde görün."
permalink: "yarisma-filtrele/"
filterGroups:
  - id: type
    label: "Yarışma Türü"
    options:
      - hikaye yarışması
      - şiir yarışması
      - roman yarışması
      - deneme yarışması
      - makale yarışması
      - resim yarışması
      - fotoğraf yarışması
      - kısa film yarışması
      - kompozisyon yarışması
      - tasarım yarışması
      - karikatür yarışması
      - mektup yarışması
      - senaryo yarışması
      - tiyatro oyunu yazma yarışması
      - masal yarışması
      - proje yarışması
      - afiş yarışması
      - beste yarışması
      - anı yarışması
      - kitap dosyası
      - kitap okuma yarışması
  - id: audience
    label: "Kimler Katılabilir?"
    options:
      - genel
      - ilkokul
      - ortaokul
      - lise
      - üniversite
      - kadın
      - öğretmen
  - id: attendance
    label: "Gönderim Şekli"
    options:
      - E-posta
      - Online/Web Sitesi
      - Kargo/Posta
      - Elden
      - Okul/Kurum
      - Sosyal Medya
      - Diğer
  - id: prize
    label: "Para Ödülü Var mı?"
    options:
      - Evet
      - Hayır
---

{% capture nowunix %}{{'now' | date: '%s'}}{% endcapture %}
{% assign nowDateInt = nowunix | plus: 0 %}
{% assign filtered_posts = site.posts | where_exp: "item", "item.lastDate > nowDateInt" %}
{% assign sorted_posts = filtered_posts | sort: 'lastDate' %}

<section class="p-2">
  <h1>Yarışma Filtrele</h1>
  <p>Yarışma türünü, kimlerin katılabileceğini ve gönderim şeklini seçerek güncel duyuruları daraltabilirsiniz. Yaşını ve kitap durumunu da girip seçimlerini kaydedersen, bu sayfa her gelişinde sadece başvurabileceğin yarışmaları gösterir.</p>

  <section id="profil-durum" class="alert alert-info" hidden></section>

  <section id="bana-ozel" class="profil-kutu mb-3">
    <h2 class="h5">Filtreler</h2>
    <section class="row">
      {% for group in page.filterGroups %}
      <section class="col-lg-3 col-md-6 col-sm-12 mb-3">
        <section class="dropdown filter-dropdown" onclick="event.stopPropagation()">
          <button class="btn btn-outline-secondary btn-block dropdown-toggle text-left" type="button"
            data-toggle="dropdown" aria-expanded="false" id="{{ group.id }}-dropdown-btn">
            {{ group.label }}
          </button>
          <section class="dropdown-menu w-100 p-2" style="max-height: 300px; overflow-y: auto;"
            aria-labelledby="{{ group.id }}-dropdown-btn">
            {% for option in group.options %}
            <label class="dropdown-item-text d-block mb-1">
              <input type="checkbox" class="filter-checkbox {{ group.id }}-checkbox" value="{{ option }}"> {{ option | tr_capitalize }}
            </label>
            {% endfor %}
          </section>
        </section>
      </section>
      {% endfor %}
    </section>
    <h3 class="h6 mt-1">Hakkında (isteğe bağlı)</h3>
    <section class="form-row">
      <section class="form-group col-lg-3 col-md-6 col-12">
        <label for="profil-dogum">Doğum yılın</label>
        <input type="number" id="profil-dogum" class="form-control" inputmode="numeric" min="1900" max="{{ 'now' | date: '%Y' }}" placeholder="ör. 1991">
      </section>
      <section class="form-group col-lg-3 col-md-6 col-12">
        <label for="profil-kitap">Yayımlanmış kitabın</label>
        <select id="profil-kitap" class="form-control">
          <option value="">Belirtmek istemiyorum</option>
          <option value="yok">Yok</option>
          <option value="bir">Bir kitabım var</option>
          <option value="cok">Birden fazla kitabım var</option>
        </select>
      </section>
      <section class="form-group col-lg-6 col-12">
        <label class="d-block"><input type="checkbox" id="profil-ucretli"> Ücretli yarışmaları gizle</label>
        <label class="d-block"><input type="checkbox" id="profil-kadin"> Sadece kadınlara açık yarışmaları gizle</label>
      </section>
    </section>
    <section class="d-flex flex-wrap align-items-center">
      <button type="button" id="profil-kaydet" class="btn btn-primary btn-sm mr-2 mb-2">Tüm seçimlerimi kaydet</button>
      <button type="button" id="filter-reset" class="btn btn-outline-secondary btn-sm mb-2">Filtreleri Temizle</button>
    </section>
    <p class="small text-muted mb-0">"Tüm seçimlerimi kaydet", bu kutudaki bütün seçimleri (yarışma türü, kimler katılabilir, gönderim şekli, para ödülü ve hakkındaki bilgiler) bu tarayıcıda hatırlar, bize gönderilmez. Yaş veya kitap şartı belirtilmemiş yarışmalar da listelenir, başvurmadan önce koşulları kontrol et.</p>
  </section>

  <section id="profil-mesaj" class="alert alert-success" role="status" hidden></section>

  <hr>

  <p id="filter-count" class="font-weight-bold">{{ sorted_posts.size }} yarışma bulundu</p>
  <section id="filter-results">
    {% for post in sorted_posts limit:30 %}
    <article>
      <h2><a href="{{ site.url }}{{ post.url }}">{{ post.title }}</a></h2>
      <p>🗓️ Yarışmanın son başvuru tarihi: <b>{{ post.dateHuman }}</b></p>
      {% if post.requirements %}<p>❗ Yarışmadaki kısıtlar: <b>{{ post.requirements }}</b></p>{% endif %}
      {% if post.attendance %}<p>📮 Gönderim şekli: <b>{{ post.attendance }}</b></p>{% endif %}
      <p>{{ post.excerpt | strip_html | strip_newlines | truncate: 160 }}</p>
    </article>
    <hr>
    {% endfor %}
  </section>
  <section class="text-center mb-4">
    <button type="button" id="filter-more" class="btn btn-primary" {% unless sorted_posts.size > 30 %}style="display:none;"{% endunless %}>Daha Fazla Göster</button>
  </section>
</section>

<script src="/js/profil.js" defer></script>
<script src="/js/yarisma-filtrele.js" defer></script>
