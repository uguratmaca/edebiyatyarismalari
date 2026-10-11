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
        <td>Sadece belirli bir kategoriyi göster. Birden fazla kategori virgülle ayrılarak yazılabilir.</td>
        <td><code>data-tip="hikaye yarışması"</code><br><code>data-tip="şiir yarışması,hikaye yarışması"</code></td>
      </tr>
      <tr>
        <td><code>data-ucretsiz</code></td>
        <td>Sadece şartnamesinde katılımın ücretsiz olduğu açıkça yazan yarışmaları göster</td>
        <td><code>data-ucretsiz="1"</code></td>
      </tr>
      <tr>
        <td><code>data-bicim</code></td>
        <td>Gönderilecek esere göre süz: <code>tek eser</code>, <code>kitap dosyası</code> (yayımlanmamış kitap bütünlüğünde dosya) veya <code>yayımlanmış kitap</code>. Virgülle birden fazlası yazılabilir.</td>
        <td><code>data-bicim="kitap dosyası"</code></td>
      </tr>
      <tr>
        <td><code>data-kitapsiz</code></td>
        <td>Sadece daha önce kitabı yayımlanmamış yazarlara açık yarışmaları göster</td>
        <td><code>data-kitapsiz="1"</code></td>
      </tr>
      <tr>
        <td><code>data-rozet</code></td>
        <td>Her yarışmanın altında "Ücretsiz", "Kitap dosyası" gibi küçük etiketler göster</td>
        <td><code>data-rozet="1"</code></td>
      </tr>
      <tr>
        <td><code>data-baslik</code></td>
        <td>Widget'ın üstünde gösterilecek başlık (boş bırakılırsa başlık gösterilmez)</td>
        <td><code>data-baslik="Güncel Yarışmalar"</code></td>
      </tr>
    </tbody>
  </table>

  <p>Parametreler birlikte kullanılabilir; birden fazla filtre verildiğinde yalnızca hepsine uyan yarışmalar listelenir. Filtrelere uyan güncel yarışma yoksa widget hiçbir şey göstermez.</p>

  <h2>Örnek Kullanımlar</h2>

  <h3>Sadece şiir yarışmaları</h3>
  <pre><code class="language-html">&lt;script src="https://edebiyatyarismalari.com/js/embed-widget.js" data-count="5" data-tip="şiir yarışması" data-baslik="Güncel Şiir Yarışmaları" async&gt;&lt;/script&gt;</code></pre>

  <h3>Öykü ve şiir yarışmaları bir arada</h3>
  <pre><code class="language-html">&lt;script src="https://edebiyatyarismalari.com/js/embed-widget.js" data-count="8" data-tip="hikaye yarışması,şiir yarışması" data-baslik="Öykü ve Şiir Yarışmaları" async&gt;&lt;/script&gt;</code></pre>

  <h3>Lise öğrencilerine yönelik yarışmalar</h3>
  <p>Okul ve öğretmen siteleri için. <code>data-tip</code> türlerin yanında kitle etiketlerini de kabul eder: <code>ilkokul</code>, <code>ortaokul</code>, <code>lise</code>, <code>üniversite</code>, <code>öğretmen</code>, <code>kadın</code>.</p>
  <pre><code class="language-html">&lt;script src="https://edebiyatyarismalari.com/js/embed-widget.js" data-count="5" data-tip="lise" data-baslik="Liselilere Edebiyat Yarışmaları" async&gt;&lt;/script&gt;</code></pre>

  <h3>Kitap dosyası ve yayımlanmış kitap yarışmaları</h3>
  <pre><code class="language-html">&lt;script src="https://edebiyatyarismalari.com/js/embed-widget.js" data-count="5" data-bicim="kitap dosyası,yayımlanmış kitap" data-baslik="Kitap Yarışmaları" async&gt;&lt;/script&gt;</code></pre>

  <h3>Henüz kitabı olmayan yazarlar için</h3>
  <pre><code class="language-html">&lt;script src="https://edebiyatyarismalari.com/js/embed-widget.js" data-count="5" data-kitapsiz="1" data-baslik="İlk Kitabını Arayanlara" async&gt;&lt;/script&gt;</code></pre>

  <h3>Katılımı ücretsiz yarışmalar, etiketleriyle</h3>
  <p>Aşağıdaki kutu bu kodun canlı önizlemesidir:</p>
  <pre><code class="language-html">&lt;script src="https://edebiyatyarismalari.com/js/embed-widget.js" data-count="5" data-ucretsiz="1" data-rozet="1" data-baslik="Ücretsiz Katılımlı Yarışmalar" async&gt;&lt;/script&gt;</code></pre>
  <section class="border rounded p-3 mb-4" style="max-width: 480px;">
    <script src="/js/embed-widget.js" data-count="5" data-ucretsiz="1" data-rozet="1" data-baslik="Ücretsiz Katılımlı Yarışmalar" async></script>
  </section>

  <h2>WordPress Kullanıyorsanız</h2>
  <p>WordPress siteniz varsa, bu genel script yerine resmi <a href="https://wordpress.com/tr/plugins/edebiyat-yarismalari-widget" target="_blank" rel="nofollow noopener">Edebiyat Yarışmaları Widget eklentisini</a> kurmanızı öneririz. Aynı listeyi <code>[edyw_widget]</code> kısa kodu ile, WordPress panelinden yönetilebilir şekilde gösterir.</p>

  <p>Kısa kod, yukarıdaki parametrelerin hepsini <code>data-</code> öneki olmadan kabul eder (<code>count</code>, <code>tip</code>, <code>baslik</code>, <code>ucretsiz</code>, <code>bicim</code>, <code>kitapsiz</code>, <code>rozet</code>). <code>ucretsiz</code>, <code>bicim</code>, <code>kitapsiz</code>, <code>rozet</code> ve virgülle birden fazla <code>tip</code> eklentinin 1.1.0 sürümüyle geldi; eski sürümü kullanıyorsanız eklentiyi güncelleyin.</p>

  <pre><code>[edyw_widget count="5" baslik="Güncel Edebiyat Yarışmaları"]

[edyw_widget count="5" tip="şiir yarışması" baslik="Güncel Şiir Yarışmaları"]

[edyw_widget count="8" tip="hikaye yarışması,şiir yarışması"]

[edyw_widget tip="lise" baslik="Liselilere Edebiyat Yarışmaları"]

[edyw_widget bicim="kitap dosyası,yayımlanmış kitap" baslik="Kitap Yarışmaları"]

[edyw_widget kitapsiz="1" baslik="İlk Kitabını Arayanlara"]

[edyw_widget ucretsiz="1" rozet="1" baslik="Ücretsiz Katılımlı Yarışmalar"]</code></pre>

  <p>Kısa kodu bir yazıya, sayfaya ya da Görünüm &gt; Bileşenler bölümündeki "Kısa kod" bileşenine ekleyerek kenar çubuğunda gösterebilirsiniz. Eklenti verileri 12 saatte bir yeniler.</p>

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
