---
layout: default
title: "Yarışma Filtrele | Sana Uygun Edebiyat Yarışmasını Bul"
description: "Yaş grubuna (ilkokul, ortaokul, lise, üniversite) ve yarışma türüne göre güncel edebiyat yarışmalarını filtreleyerek listeleyin."
permalink: "yarisma-filtrele/"
filterGroups:
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
---

<section class="p-2">
  <h1>Yarışma Filtrele</h1>
  <p>Kimlerin katılabileceğini, yarışma türünü ve gönderim şeklini seçerek güncel duyuruları daraltabilirsiniz. (Deneme sürümü)</p>

  <section class="row">
    {% for group in page.filterGroups %}
    <section class="col-md-4 col-sm-12 mb-3">
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

  <section class="mb-3">
    <button type="button" id="filter-reset" class="btn btn-outline-secondary btn-sm">Filtreleri Temizle</button>
  </section>

  <hr>

  <p id="filter-count" class="font-weight-bold"></p>
  <section id="filter-results"></section>
  <section class="text-center mb-4">
    <button type="button" id="filter-more" class="btn btn-primary" style="display:none;">Daha Fazla Göster</button>
  </section>
</section>

<script src="/js/yarisma-filtrele.js" defer></script>
