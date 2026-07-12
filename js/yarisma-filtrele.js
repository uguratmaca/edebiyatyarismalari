(function () {
  var PAGE_SIZE = 30;
  var allPosts = [];
  var visibleCount = PAGE_SIZE;

  // Mirrors _plugins/attendance_normalizer.rb. Done client-side (instead of
  // relying on the post.attendanceMethods field baked into yarismalar.json)
  // because that field was observed to come through unnormalized in
  // production despite building correctly locally - keeping this logic here
  // makes the filter correct regardless of what the JSON contains.
  var EPOSTA_PATTERN = /e[\s-]?post\w*|e[\s-]?mail/i;
  var OTHER_CATEGORIES = [
    ['Online/Web Sitesi', /web ?sitesi|wesitesi|online|internet sitesi|e-?devlet|çevrimiçi/i],
    ['Kargo/Posta', /kargo|posta|ptt|aps\b/i],
    ['Elden', /elden|şahsen|yüz ?yüze|teslim/i],
    ['Okul/Kurum', /okul|müdürl|müftül|milli eğitim|öğretmen|veli|kurum|danışman|konsoloslu|bilgi evi|gençlik merkezi/i],
    ['Sosyal Medya', /instagram|facebook|twitter|whatsapp|telegram|sosyal medya|mesaj/i]
  ];

  function normalizeAttendance(input) {
    if (!input) return [];
    var text = String(input).replace(/İ/g, 'i');
    var matched = [];

    if (EPOSTA_PATTERN.test(text)) {
      matched.push('E-posta');
      text = text.replace(EPOSTA_PATTERN, '');
    }

    OTHER_CATEGORIES.forEach(function (entry) {
      if (entry[1].test(text)) matched.push(entry[0]);
    });

    return matched.length ? matched : ['Diğer'];
  }

  var resultsEl = document.getElementById('filter-results');
  var countEl = document.getElementById('filter-count');
  var moreBtn = document.getElementById('filter-more');
  var resetBtn = document.getElementById('filter-reset');

  function getSelected(className) {
    var boxes = document.querySelectorAll('.' + className + ':checked');
    return Array.prototype.map.call(boxes, function (box) { return box.value; });
  }

  function matchesFilters(post, audience, types, attendanceMethods) {
    var tags = post.tags || [];
    var methods = normalizeAttendance(post.attendance);
    var audienceMatch = audience.length === 0 || audience.some(function (a) { return tags.indexOf(a) !== -1; });
    var typeMatch = types.length === 0 || types.some(function (t) { return tags.indexOf(t) !== -1; });
    var attendanceMatch = attendanceMethods.length === 0 || attendanceMethods.some(function (m) { return methods.indexOf(m) !== -1; });
    return audienceMatch && typeMatch && attendanceMatch;
  }

  function cardHtml(post) {
    var requirementsHtml = post.requirements
      ? '<p>❗ Yarışmadaki kısıtlar: <b>' + post.requirements + '</b></p>'
      : '';
    var attendanceHtml = post.attendance
      ? '<p>📮 Gönderim şekli: <b>' + post.attendance + '</b></p>'
      : '';
    return (
      '<article>' +
      '<h2><a href="' + post.url + '">' + post.title + '</a></h2>' +
      '<p>🗓️ Yarışmanın son başvuru tarihi: <b>' + post.dateHuman + '</b></p>' +
      requirementsHtml +
      attendanceHtml +
      '<p>' + post.excerpt + '</p>' +
      '</article><hr>'
    );
  }

  function render() {
    var audience = getSelected('audience-checkbox');
    var types = getSelected('type-checkbox');
    var attendanceMethods = getSelected('attendance-checkbox');
    var filtered = allPosts.filter(function (post) {
      return matchesFilters(post, audience, types, attendanceMethods);
    });

    countEl.textContent = filtered.length + ' yarışma bulundu';

    var toShow = filtered.slice(0, visibleCount);
    resultsEl.innerHTML = toShow.length
      ? toShow.map(cardHtml).join('')
      : '<p>Seçtiğiniz kriterlere uygun aktif yarışma bulunamadı.</p>';

    moreBtn.style.display = filtered.length > visibleCount ? 'inline-block' : 'none';
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
    updateDropdownLabels();
    render();
  }

  document.querySelectorAll('.filter-checkbox').forEach(function (box) {
    box.addEventListener('change', onFilterChange);
  });

  resetBtn.addEventListener('click', function () {
    document.querySelectorAll('.filter-checkbox').forEach(function (box) { box.checked = false; });
    onFilterChange();
  });

  moreBtn.addEventListener('click', function () {
    visibleCount += PAGE_SIZE;
    render();
  });

  fetch('/yarismalar.json')
    .then(function (res) { return res.json(); })
    .then(function (data) {
      allPosts = data.sort(function (a, b) { return a.lastDate - b.lastDate; });
      render();
    })
    .catch(function () {
      countEl.textContent = '';
      resultsEl.innerHTML = '<p>Yarışmalar yüklenirken bir hata oluştu.</p>';
    });
})();
