// Ana sayfadaki "bana özel" kutusu: tercih kaydetmiş ziyaretçiye uygun ve yeni yarışma sayısını gösterir.
// Tercih yoksa sunucuda üretilen davet metni olduğu gibi kalır (yarismalar.json hiç çekilmez).
(function () {
  var Profil = window.EDYProfil;
  var textEl = document.getElementById('bana-ozel-metin');
  var profile = Profil && Profil.load();
  if (!textEl || !profile) return;

  var lastSeen = Profil.lastSeen() || Math.floor(profile.savedAt / 1000);

  fetch('/yarismalar.json')
    .then(function (res) { return res.json(); })
    .then(function (posts) {
      var matching = posts.filter(function (post) { return Profil.matches(post, profile); });
      var fresh = matching.filter(function (post) { return post.date && post.date > lastSeen; });
      textEl.innerHTML =
        '🎯 Kayıtlı seçimlerine uygun <b>' + matching.length + '</b> açık yarışma var' +
        (fresh.length ? ' (<b>' + fresh.length + '</b> yeni)' : '') +
        ': <a href="' + textEl.getAttribute('data-link') + '">Bana özel yarışmaları gör</a>';
    })
    .catch(function () {});
})();
