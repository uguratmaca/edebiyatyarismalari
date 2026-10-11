(function () {
  var FEED_URL = 'https://edebiyatyarismalari.com/yarismalar.json';
  var STYLE_ID = 'edyw-embed-style';

  var scriptEl = document.currentScript;
  if (!scriptEl) return;

  var count = parseInt(scriptEl.getAttribute('data-count'), 10);
  if (!count || count < 1) count = 5;
  var tip = (scriptEl.getAttribute('data-tip') || '').trim();
  var baslik = scriptEl.getAttribute('data-baslik') || '';
  var ucretsiz = scriptEl.getAttribute('data-ucretsiz') === '1';
  var bicim = (scriptEl.getAttribute('data-bicim') || '').trim();
  var kitapsiz = scriptEl.getAttribute('data-kitapsiz') === '1';
  var rozet = scriptEl.getAttribute('data-rozet') === '1';

  var container = document.createElement('div');
  container.className = 'edyw-widget';
  scriptEl.parentNode.insertBefore(container, scriptEl.nextSibling);

  injectStyle();

  fetch(FEED_URL)
    .then(function (res) {
      if (!res.ok) throw new Error('network');
      return res.json();
    })
    .then(function (items) {
      render(Array.isArray(items) ? items : []);
    })
    .catch(function () {
      container.remove();
    });

  function render(items) {
    // data-tip virgülle ayrılmış birden fazla tag alabilir, herhangi biri eşleşirse gösterilir.
    var tipList = splitList(tip);
    if (tipList.length) {
      items = items.filter(function (item) {
        return Array.isArray(item.tags) && item.tags.some(function (t) {
          return tipList.indexOf(lower(t)) !== -1;
        });
      });
    }

    // Sadece şartnamesinde açıkça "Ücretsiz" yazanlar; entryFee alanı boş olanlar gösterilmez.
    if (ucretsiz) {
      items = items.filter(function (item) {
        return lower(item.entryFee) === 'ücretsiz';
      });
    }

    // submissionType yoksa yarışma tek eser kabul eder.
    var bicimList = splitList(bicim);
    if (bicimList.length) {
      items = items.filter(function (item) {
        return submissionTypes(item).some(function (s) {
          return bicimList.indexOf(lower(s)) !== -1;
        });
      });
    }

    if (kitapsiz) {
      items = items.filter(function (item) {
        return lower(item.authorCondition) === 'kitabı olmayanlar';
      });
    }

    items = items.slice(0, count);

    if (!items.length) {
      container.remove();
      return;
    }

    var html = '';

    if (baslik) {
      html += '<h3 class="edyw-widget__title">' + escapeHtml(baslik) + '</h3>';
    }

    html += '<ul class="edyw-widget__list">';
    items.forEach(function (item) {
      html += '<li class="edyw-widget__item">';
      html += '<a href="' + escapeHtml(item.url || '#') + '" rel="nofollow sponsored noopener" target="_blank">' + escapeHtml(item.title || '') + '</a>';
      if (item.dateHuman) {
        html += '<span class="edyw-widget__date">Son başvuru: ' + escapeHtml(item.dateHuman) + '</span>';
      }
      if (item.totalPrize) {
        html += '<span class="edyw-widget__prize">Ödül: ' + escapeHtml(item.totalPrize) + '</span>';
      }
      if (rozet) {
        html += badgesHtml(item);
      }
      html += '</li>';
    });
    html += '</ul>';

    html += '<p class="edyw-widget__credit">Kaynak: <a href="https://edebiyatyarismalari.com" rel="nofollow sponsored noopener" target="_blank">edebiyatyarismalari.com</a></p>';

    container.innerHTML = html;
  }

  function lower(str) {
    return String(str == null ? '' : str).trim().toLocaleLowerCase('tr');
  }

  function splitList(str) {
    return str ? str.split(',').map(lower).filter(Boolean) : [];
  }

  function submissionTypes(item) {
    return Array.isArray(item.submissionType) && item.submissionType.length ? item.submissionType : ['tek eser'];
  }

  function badgesHtml(item) {
    var labels = [];
    if (lower(item.entryFee) === 'ücretsiz') labels.push('Ücretsiz');
    var types = submissionTypes(item).map(lower);
    if (types.indexOf('kitap dosyası') !== -1) labels.push('Kitap dosyası');
    if (types.indexOf('yayımlanmış kitap') !== -1) labels.push('Yayımlanmış kitap');
    if (lower(item.authorCondition) === 'kitabı olmayanlar') labels.push('Kitabı olmayanlara');
    if (lower(item.authorCondition) === 'ilk kitap') labels.push('İlk kitap');
    if (!labels.length) return '';
    return '<span class="edyw-widget__badges">' + labels.map(function (l) {
      return '<span class="edyw-widget__badge">' + escapeHtml(l) + '</span>';
    }).join('') + '</span>';
  }

  function escapeHtml(str) {
    return String(str).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }

  function injectStyle() {
    if (document.getElementById(STYLE_ID)) return;
    var style = document.createElement('style');
    style.id = STYLE_ID;
    style.textContent =
      '.edyw-widget{font-family:inherit;margin:1em 0}' +
      '.edyw-widget__title{margin:0 0 .5em}' +
      '.edyw-widget__list{list-style:none;margin:0;padding:0}' +
      '.edyw-widget__item{padding:.5em 0;border-bottom:1px solid rgba(0,0,0,.1)}' +
      '.edyw-widget__item:last-child{border-bottom:none}' +
      '.edyw-widget__date{display:block;font-size:.85em;opacity:.75}' +
      '.edyw-widget__prize{display:block;font-size:.85em;font-weight:600}' +
      '.edyw-widget__badges{display:block;margin-top:.25em}' +
      '.edyw-widget__badge{display:inline-block;margin:0 .35em .2em 0;padding:0 .45em;font-size:.75em;line-height:1.6;border:1px solid currentColor;border-radius:3px;opacity:.8}' +
      '.edyw-widget__credit{margin-top:.75em;font-size:.8em;opacity:.7}';
    document.head.appendChild(style);
  }
})();
