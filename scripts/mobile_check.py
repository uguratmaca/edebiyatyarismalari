"""
Telefon genişliğinde yatay taşma kontrolü: sayfa ekrandan genişse (yana
kayıyorsa) hata verir ve taşan öğeleri listeler.

Derlenmiş siteyi (_site) yerelde sunar, her sayfayı iPhone 13 (390 px) ve
360 px genişlikte açar; document.documentElement.scrollWidth ekran
genişliğine eşit olmalı.

Kurulum (bir kez): pip install playwright==1.63.0
(Tarayıcı olarak kurulu Chrome kullanılır; yoksa: python -m playwright install chromium
ve CHANNEL = None.)

    bundle exec jekyll build
    python scripts/mobile_check.py                      # varsayılan sayfalar
    python scripts/mobile_check.py /yarisma-filtrele/   # belirli sayfalar
"""

import functools
import http.server
import sys
import threading
from pathlib import Path

from playwright.sync_api import sync_playwright

SITE = Path(__file__).resolve().parent.parent / "_site"
PAGES = ["/", "/hekimoglu-ismail-hikaye-yarismasi-2026.html", "/yarisma-filtrele/", "/hikaye-yarismalari/",
         "/her-yil-tekrarlanan-yarismalar/", "/404.html"]
WIDTHS = [("iPhone 13", None), ("360 px", {"width": 360, "height": 740})]
CHANNEL = "chrome"

# Ekranın sağından taşan öğeler (en fazla 8), seçici ve genişlikleriyle.
OVERFLOW = """() => {
  const vw = document.documentElement.clientWidth, out = [];
  for (const el of document.querySelectorAll('body *')) {
    const r = el.getBoundingClientRect();
    if (r.width > 0 && r.right > vw + 1) {
      const name = el.tagName.toLowerCase() + (el.id ? '#' + el.id : '') +
        (el.className && typeof el.className === 'string' ? '.' + el.className.trim().split(/\\s+/).join('.') : '');
      out.push(name + ' (sağ kenar ' + Math.round(r.right) + ' px)');
      if (out.length >= 8) break;
    }
  }
  return out;
}"""


LIVE = "https://edebiyatyarismalari.com"


def local_file(route, request) -> None:
    """Canlı siteye giden istek, dosya _site'ta varsa oradan karşılanır."""
    path = request.url[len(LIVE):].split("?")[0].split("#")[0] or "/"
    local = SITE / path.lstrip("/")
    if local.is_file():
        route.fulfill(path=local)
    else:
        route.continue_()


def serve() -> int:
    class Quiet(http.server.SimpleHTTPRequestHandler):
        def log_message(self, *args):
            pass
    handler = functools.partial(Quiet, directory=str(SITE))
    server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server.server_address[1]


def main() -> int:
    pages = sys.argv[1:] or PAGES
    port = serve()
    failed = 0
    with sync_playwright() as p:
        browser = p.chromium.launch(channel=CHANNEL)
        for label, viewport in WIDTHS:
            options = dict(p.devices["iPhone 13"]) if viewport is None else {
                **p.devices["iPhone 13"], "viewport": viewport}
            options.pop("default_browser_type", None)
            context = browser.new_context(**options)
            # Sayfalar CSS/JS'i tam adresle (site.url) yükler: bunlar da yerel derlemeden gelsin,
            # yoksa canlı sitenin dosyaları test edilir.
            context.route(f"{LIVE}/**", local_file)
            page = context.new_page()
            for path in pages:
                page.goto(f"http://127.0.0.1:{port}{path}", wait_until="load")
                scroll, client = page.evaluate(
                    "() => [document.documentElement.scrollWidth, document.documentElement.clientWidth]")
                if scroll > client:
                    failed += 1
                    print(f"TAŞIYOR  {label:9} {path}: sayfa {scroll} px, ekran {client} px")
                    for item in page.evaluate(OVERFLOW):
                        print(f"           {item}")
                else:
                    print(f"tamam    {label:9} {path}")
            context.close()
        browser.close()
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
