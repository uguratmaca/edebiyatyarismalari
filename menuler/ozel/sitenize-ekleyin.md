---
layout: default
title: "Sitenize Güncel Edebiyat Yarışmalarını Ekleyin | Ücretsiz Widget"
description: "Blogger, Wix, Squarespace veya herhangi bir web sitesine tek satır kodla güncel edebiyat yarışmalarını otomatik listeleyen ücretsiz widget. Kayıt, API anahtarı gerekmez."
permalink: "sitenize-ekleyin/"
---

<section class="p-2">
  <h1>Sitenize Güncel Edebiyat Yarışmalarını Ekleyin</h1>

  <p>edebiyatyarismalari.com'daki güncel şiir, öykü, roman ve diğer edebiyat yarışması duyurularını kendi sitenizde otomatik olarak listeleyebilirsiniz. Tamamen ücretsiz, kayıt ya da API anahtarı gerekmez; sayfanıza tek satır kod yapıştırmanız yeterli.</p>

  <h2>Canlı Önizleme</h2>
  <p>Aşağıdaki kutu, widget'ın sitenizde nasıl görüneceğinin canlı bir örneğidir:</p>

  <section class="border rounded p-3 mb-4" style="max-width: 480px;">
    <script src="/js/embed-widget.js" data-count="5" data-baslik="Güncel Edebiyat Yarışmaları" async></script>
  </section>

  <h2>Nasıl Eklenir?</h2>
  <p>Sitenizin HTML'ini düzenleyebildiğiniz herhangi bir yere (Blogger'da HTML/JavaScript gadget'ı, Wix veya Squarespace'in kod ekleme/embed bloğu, WordPress'te özel HTML bloğu, ya da düz bir HTML sayfası) aşağıdaki kodu yapıştırmanız yeterli:</p>

  <pre><code class="language-html">&lt;script src="https://edebiyatyarismalari.com/js/embed-widget.js" data-count="5" data-baslik="Güncel Edebiyat Yarışmaları" async&gt;&lt;/script&gt;</code></pre>

  <p>Script, bulunduğu yere kendi listesini basar; ayrıca bir <code>&lt;div&gt;</code> ya da CSS dosyası eklemenize gerek yoktur.</p>

  <h2>Parametreler</h2>
  <table class="table">
    <thead>
      <tr>
        <th>Parametre</th>
        <th>Açıklama</th>
        <th>Örnek</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><code>data-count</code></td>
        <td>Listelenecek yarışma sayısı (varsayılan: 5)</td>
        <td><code>data-count="3"</code></td>
      </tr>
      <tr>
        <td><code>data-tip</code></td>
        <td>Sadece belirli bir kategoriyi göster</td>
        <td><code>data-tip="hikaye yarışması"</code></td>
      </tr>
      <tr>
        <td><code>data-baslik</code></td>
        <td>Widget'ın üstünde gösterilecek başlık (boş bırakılırsa başlık gösterilmez)</td>
        <td><code>data-baslik="Güncel Yarışmalar"</code></td>
      </tr>
    </tbody>
  </table>

  <h2>WordPress Kullanıyorsanız</h2>
  <p>WordPress siteniz varsa, bu genel script yerine resmi <a href="https://wordpress.com/tr/plugins/edebiyat-yarismalari-widget" target="_blank" rel="nofollow noopener">Edebiyat Yarışmaları Widget eklentisini</a> kurmanızı öneririz. Aynı listeyi <code>[edyw_widget]</code> kısa kodu ile, WordPress panelinden yönetilebilir şekilde gösterir.</p>

  <h2>Sıkça Sorulan Sorular</h2>

  <h3>Bu widget ücretsiz mi?</h3>
  <p>Evet. edebiyatyarismalari.com tarafından ücretsiz sunulur; kayıt, API anahtarı veya herhangi bir ödeme gerekmez.</p>

  <h3>Hangi sitelerde çalışır?</h3>
  <p>Bir <code>&lt;script&gt;</code> etiketi kabul eden her platformda çalışır: Blogger, Wix, Squarespace, WordPress (özel HTML bloğu) ve düz HTML siteler dahil. WordPress kullanıcıları için ayrıca yukarıda bahsedilen özel bir eklenti de mevcut.</p>

  <h3>Veriler ne sıklıkla güncelleniyor?</h3>
  <p>Widget, sayfanız her yüklendiğinde edebiyatyarismalari.com'daki güncel listeyi anlık olarak çeker; kaynak veri en fazla birkaç dakikada bir tazelenir.</p>

  <h3>Linkler dofollow mu?</h3>
  <p>Hayır. Widget içindeki tüm bağlantılar <code>rel="nofollow sponsored noopener"</code> ile işaretlidir.</p>

  <h3>Ziyaretçilerimin verisi toplanıyor mu?</h3>
  <p>Hayır. Widget yalnızca herkese açık, parametre içermeyen bir JSON adresine istek yapar; ziyaretçiye ait hiçbir veri (IP, çerez, tarayıcı bilgisi) gönderilmez ya da toplanmaz.</p>
</section>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Bu widget ücretsiz mi?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Evet. edebiyatyarismalari.com tarafından ücretsiz sunulur; kayıt, API anahtarı veya herhangi bir ödeme gerekmez."
      }
    },
    {
      "@type": "Question",
      "name": "Hangi sitelerde çalışır?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Bir script etiketi kabul eden her platformda çalışır: Blogger, Wix, Squarespace, WordPress (özel HTML bloğu) ve düz HTML siteler dahil. WordPress kullanıcıları için ayrıca özel bir eklenti de mevcuttur."
      }
    },
    {
      "@type": "Question",
      "name": "Veriler ne sıklıkla güncelleniyor?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Widget, sayfa her yüklendiğinde edebiyatyarismalari.com'daki güncel listeyi anlık olarak çeker; kaynak veri en fazla birkaç dakikada bir tazelenir."
      }
    },
    {
      "@type": "Question",
      "name": "Linkler dofollow mu?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Hayır. Widget içindeki tüm bağlantılar rel=\"nofollow sponsored noopener\" ile işaretlidir."
      }
    },
    {
      "@type": "Question",
      "name": "Ziyaretçilerimin verisi toplanıyor mu?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Hayır. Widget yalnızca herkese açık, parametre içermeyen bir JSON adresine istek yapar; ziyaretçiye ait hiçbir veri gönderilmez ya da toplanmaz."
      }
    }
  ]
}
</script>
