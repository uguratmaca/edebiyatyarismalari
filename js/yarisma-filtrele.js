(function () {
  var PAGE_SIZE = 30;
  var GROUPS = ['type', 'audience', 'attendance', 'prize'];
  var Profil = window.EDYProfil;
  var allPosts = [];
  var visibleCount = PAGE_SIZE;
  var saved = Profil.load();
  // "Yeni" rozeti, bu ziyaretten önceki son bakışa göre hesaplanır.
  var lastSeen = Profil.lastSeen() || (saved ? Math.floor(saved.savedAt / 1000) : null);

  var resultsEl = document.getElementById('filter-results');
  var countEl = document.getElementById('filter-count');
  var moreBtn = document.getElementById('filter-more');
  var resetBtn = document.getElementById('filter-reset');
  var birthEl = document.getElementById('profil-dogum');
  var bookEl = document.getElementById('profil-kitap');
  var paidEl = document.getElementById('profil-ucretli');
  var womenEl = document.getElementById('profil-kadin');
  var saveBtn = document.getElementById('profil-kaydet');
  var statusEl = document.getElementById('profil-durum');
  var messageEl = document.getElementById('profil-mesaj');

  function escapeHtml(str) {
    return String(str).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }

  function getSelected(group) {
    var boxes = document.querySelectorAll('.' + group + '-checkbox:checked');
    return Array.prototype.map.call(boxes, function (box) { return box.value; });
  }

  function currentProfile() {
    var p = {};
    GROUPS.forEach(function (g) { p[g] = getSelected(g); });
    var year = parseInt(birthEl.value, 10);
    var thisYear = new Date().getFullYear();
    p.birthYear = year >= 1900 && year <= thisYear ? year : null;
    p.book = bookEl.value || null;
    p.hidePaid = paidEl.checked;
    p.hideWomenOnly = womenEl.checked;
    return p;
  }

  function applyProfile(p) {
    GROUPS.forEach(function (g) {
      var values = p[g] || [];
      document.querySelectorAll('.' + g + '-checkbox').forEach(function (box) {
        box.checked = values.indexOf(box.value) !== -1;
      });
    });
    birthEl.value = p.birthYear || '';
    bookEl.value = p.book || '';
    paidEl.checked = !!p.hidePaid;
    womenEl.checked = !!p.hideWomenOnly;
  }

  function normalized(p) {
    var n = {};
    GROUPS.forEach(function (g) { n[g] = (p[g] || []).slice().sort(); });
    n.birthYear = p.birthYear || null;
    n.book = p.book || null;
    n.hidePaid = !!p.hidePaid;
    n.hideWomenOnly = !!p.hideWomenOnly;
    return JSON.stringify(n);
  }

  function sameAsSaved(p) {
    return !!saved && normalized(p) === normalized(saved);
  }

  function isNew(post) {
    return lastSeen && post.date && post.date > lastSeen;
  }

  function cardHtml(post) {
    var badge = isNew(post) ? ' <span class="badge badge-success">Yeni</span>' : '';
    var requirementsHtml = post.requirements
      ? '<p>❗ Yarışmadaki kısıtlar: <b>' + escapeHtml(post.requirements) + '</b></p>'
      : '';
    var attendanceHtml = post.attendance
      ? '<p>📮 Gönderim şekli: <b>' + escapeHtml(post.attendance) + '</b></p>'
      : '';
    var submissionHtml = post.submissionType && post.submissionType.length
      ? '<p>📚 Başvuru biçimi: <b>' + escapeHtml(post.submissionType.join(' veya ')) + '</b></p>'
      : '';
    return (
      '<article>' +
      '<h2><a href="' + escapeHtml(post.url) + '">' + escapeHtml(post.title) + '</a>' + badge + '</h2>' +
      '<p>🗓️ Yarışmanın son başvuru tarihi: <b>' + escapeHtml(post.dateHuman) + '</b></p>' +
      requirementsHtml +
      attendanceHtml +
      submissionHtml +
      '<p>' + escapeHtml(post.excerpt || '') + '</p>' +
      '</article><hr>'
    );
  }

  function renderStatus(p) {
    if (!saved) {
      statusEl.hidden = true;
      saveBtn.textContent = 'Tüm seçimlerimi kaydet';
      return;
    }
    var unsaved = !sameAsSaved(p);
    statusEl.innerHTML =
      '📌 <b>Kayıtlı seçimlerinle gösteriliyor:</b> ' + escapeHtml(Profil.summary(saved)) +
      (unsaved ? ' <em>(kaydedilmemiş değişiklikler var)</em>' : '') +
      ' · <a href="#bana-ozel">Değiştir</a>' +
      ' · <button type="button" class="btn btn-link btn-sm p-0 align-baseline" id="profil-sil">Kaydı sil</button>';
    statusEl.hidden = false;
    saveBtn.textContent = unsaved ? 'Değişiklikleri kaydet' : 'Seçimlerin kayıtlı';
    document.getElementById('profil-sil').addEventListener('click', onClear);
  }

  function showMessage(html) {
    messageEl.innerHTML = html;
    messageEl.hidden = false;
  }

  function render() {
    var p = currentProfile();
    var filtered = allPosts.filter(function (post) { return Profil.matches(post, p); });

    countEl.textContent = filtered.length + ' yarışma bulundu';

    var toShow = filtered.slice(0, visibleCount);
    resultsEl.innerHTML = toShow.length
      ? toShow.map(cardHtml).join('')
      : '<p>Seçtiğiniz kriterlere uygun aktif yarışma bulunamadı.</p>';

    moreBtn.style.display = filtered.length > visibleCount ? 'inline-block' : 'none';
    renderStatus(p);
  }

  function updateDropdownLabels() {
    document.querySelectorAll('.filter-dropdown').forEach(function (group) {
      var btn = group.querySelector('.dropdown-toggle');
      if (!btn.dataset.label) {
        btn.dataset.label = btn.textContent.trim();
      }
      var checkedCount = group.querySelectorAll('.filter-checkbox:checked').length;
      btn.textContent = checkedCount ? btn.dataset.label + ' (' + checkedCount + ')' : btn.dataset.label;
    });
  }

  function onFilterChange() {
    visibleCount = PAGE_SIZE;
    messageEl.hidden = true;
    updateDropdownLabels();
    render();
  }

  function onSave() {
    var p = currentProfile();
    if (!Profil.save(p)) {
      showMessage('Seçimler kaydedilemedi. Tarayıcın site verilerini kaydetmeye izin vermiyor olabilir (ör. gizli sekme).');
      return;
    }
    saved = Profil.load();
    showMessage(
      '✅ <b>Seçimlerin kaydedildi:</b> ' + escapeHtml(Profil.summary(saved)) + '. ' +
      'Bu sayfaya bir dahaki gelişinde bu seçimlerle listelenecek. Sadece bu tarayıcıda saklanır, bize gönderilmez.'
    );
    render();
  }

  function onClear() {
    Profil.clear();
    saved = null;
    applyProfile({});
    showMessage('Kayıtlı seçimlerin silindi. Tüm açık yarışmalar listeleniyor.');
    updateDropdownLabels();
    render();
  }

  document.querySelectorAll('.filter-checkbox').forEach(function (box) {
    box.addEventListener('change', onFilterChange);
  });
  [bookEl, paidEl, womenEl].forEach(function (el) {
    el.addEventListener('change', onFilterChange);
  });
  birthEl.addEventListener('input', onFilterChange);
  saveBtn.addEventListener('click', onSave);

  resetBtn.addEventListener('click', function () {
    applyProfile({});
    onFilterChange();
  });

  moreBtn.addEventListener('click', function () {
    visibleCount += PAGE_SIZE;
    render();
  });

  if (saved) {
    applyProfile(saved);
    updateDropdownLabels();
  }

  fetch('/yarismalar.json')
    .then(function (res) { return res.json(); })
    .then(function (data) {
      allPosts = data.sort(function (a, b) { return a.lastDate - b.lastDate; });
      render();
      Profil.markSeen();
    })
    .catch(function () {
      countEl.textContent = '';
      resultsEl.innerHTML = '<p>Yarışmalar yüklenirken bir hata oluştu.</p>';
    });
})();
