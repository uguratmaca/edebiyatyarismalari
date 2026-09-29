// Ziyaretçinin kayıtlı yarışma tercihleri (sadece bu tarayıcıda, localStorage).
// Filtre sayfası (yarisma-filtrele.js) ve ana sayfa kutusu (bana-ozel-kutu.js) ortak kullanır.
(function (w) {
  var PROFILE_KEY = 'edy-profil';
  var SEEN_KEY = 'edy-son-bakis';
  var SCHOOL_AGES = { 'ilkokul': [6, 10], 'ortaokul': [10, 14], 'lise': [14, 18] };
  var ADULT_TAGS = ['genel', 'üniversite', 'öğretmen', 'kadın'];
  var BOOK_LABELS = { yok: 'Kitabım yok', bir: 'Bir kitabım var', cok: 'Birden fazla kitabım var' };

  // Gizli sekme veya kapalı depolamada localStorage hata verebilir, sayfa yine çalışmalı.
  function read(key) {
    try {
      var raw = w.localStorage.getItem(key);
      return raw ? JSON.parse(raw) : null;
    } catch (e) {
      return null;
    }
  }

  function write(key, value) {
    try {
      w.localStorage.setItem(key, JSON.stringify(value));
      return true;
    } catch (e) {
      return false;
    }
  }

  function remove(key) {
    try {
      w.localStorage.removeItem(key);
    } catch (e) {}
  }

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

  function hasAny(list, values) {
    return values.some(function (v) { return list.indexOf(v) !== -1; });
  }

  function parseAgeRange(range) {
    var m = /^\s*(\d*)\s*-\s*(\d*)\s*$/.exec(range || '');
    if (!m || (!m[1] && !m[2])) return null;
    return [m[1] ? +m[1] : 0, m[2] ? +m[2] : 200];
  }

  // Yaşı bilinmeyen (alanı boş) yarışmalar elenmez: "bilinmiyor" ile "kısıt yok" ayrımı
  // yapılamadığı için gösterip koşulları kontrol etmeyi kullanıcıya bırakıyoruz.
  function ageFits(post, age) {
    var tags = post.tags || [];
    // Doğum günü henüz gelmemiş olabilir, iki olası yaştan biri uyuyorsa uygun say.
    var ages = [age - 1, age];
    var inRange = function (r) {
      return ages.some(function (a) { return a >= r[0] && a <= r[1]; });
    };

    var range = parseAgeRange(post.typicalAgeRange);
    if (range && !inRange(range)) return false;

    if (!hasAny(tags, ADULT_TAGS)) {
      var levels = Object.keys(SCHOOL_AGES).filter(function (l) { return tags.indexOf(l) !== -1; });
      if (levels.length) {
        return levels.some(function (l) { return inRange(SCHOOL_AGES[l]); });
      }
    }

    if (tags.indexOf('üniversite') !== -1 && tags.indexOf('genel') === -1 && age < 17) return false;
    return true;
  }

  function bookFits(post, book) {
    var types = post.submissionType || [];
    var condition = post.authorCondition;

    if (book === 'yok') {
      // Sadece basılmış kitapla başvurulan ödüller kitabı olmayana uymaz.
      return !(types.length && types.every(function (t) { return t === 'yayımlanmış kitap'; }));
    }
    if (condition === 'kitabı olmayanlar') return false;
    if (book === 'cok' && condition === 'ilk kitap') return false;
    return true;
  }

  function isWomenOnly(post) {
    var requirements = String(post.requirements || '').toLocaleLowerCase('tr');
    return (post.tags || []).indexOf('kadın') !== -1 && requirements.indexOf('kadın') !== -1;
  }

  function ageOf(profile) {
    return profile && profile.birthYear ? new Date().getFullYear() - profile.birthYear : null;
  }

  function matches(post, p) {
    var tags = post.tags || [];
    var type = p.type || [];
    var audience = p.audience || [];
    var attendance = p.attendance || [];
    var prize = p.prize || [];

    if (type.length && !hasAny(tags, type)) return false;
    if (audience.length && !hasAny(tags, audience)) return false;
    if (attendance.length && !hasAny(normalizeAttendance(post.attendance), attendance)) return false;

    if (prize.length) {
      // totalPrize is only filled for cash prizes (see .claude/notes-post-schema.md).
      var hasPrize = !!(post.totalPrize && String(post.totalPrize).trim());
      if (prize.indexOf(hasPrize ? 'Evet' : 'Hayır') === -1) return false;
    }

    var age = ageOf(p);
    if (age !== null && !ageFits(post, age)) return false;
    if (p.book && !bookFits(post, p.book)) return false;
    if (p.hidePaid && post.entryFee && post.entryFee !== 'Ücretsiz') return false;
    if (p.hideWomenOnly && isWomenOnly(post)) return false;
    return true;
  }

  function summary(p) {
    var parts = [];
    var age = ageOf(p);
    if (age !== null) parts.push(age + ' yaş');
    if (p.type && p.type.length) parts.push(p.type.join(', '));
    if (p.audience && p.audience.length) parts.push(p.audience.join(', '));
    if (p.attendance && p.attendance.length) parts.push(p.attendance.join(', '));
    if (p.prize && p.prize.length === 1) parts.push(p.prize[0] === 'Evet' ? 'Para ödüllü' : 'Para ödülsüz');
    if (p.book) parts.push(BOOK_LABELS[p.book]);
    if (p.hidePaid) parts.push('Ücretliler hariç');
    if (p.hideWomenOnly) parts.push('Kadınlara özel olanlar hariç');
    return parts.length ? parts.join(' · ') : 'Tüm yarışmalar';
  }

  w.EDYProfil = {
    load: function () {
      var p = read(PROFILE_KEY);
      return p && p.v === 1 ? p : null;
    },
    save: function (p) {
      p.v = 1;
      p.savedAt = Date.now();
      return write(PROFILE_KEY, p);
    },
    clear: function () {
      remove(PROFILE_KEY);
    },
    // Unix saniye: ziyaretçinin filtre sayfasını en son açtığı an ("yeni" rozetleri için).
    lastSeen: function () {
      return read(SEEN_KEY);
    },
    markSeen: function () {
      write(SEEN_KEY, Math.floor(Date.now() / 1000));
    },
    matches: matches,
    summary: summary
  };
})(window);
