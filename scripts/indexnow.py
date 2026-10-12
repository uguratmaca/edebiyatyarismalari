"""
IndexNow: tells Bing, Yandex, Seznam and Naver (one shares with the others)
which pages a deploy added, changed or removed, so they are crawled within
minutes instead of whenever the sitemap is read next. Google doesn't take
part and keeps reading the sitemap.

Two steps in .github/workflows/jekyll.yml, standard library only:

    # build job, before the deploy: the live sitemap vs the new one
    python scripts/indexnow.py diff --new _site/sitemap.xml > urls.txt
    # indexnow job, after the deploy
    python scripts/indexnow.py send < urls.txt

"diff" lists every URL that is new, has a new <lastmod> (git-based, see
_plugins/fast_last_modified_at.rb) or is gone, plus the homepage when
anything changed. If the live sitemap can't be read it lists nothing,
rather than every page. "send" first waits until a new page is live
(GitHub Pages can lag the deploy a little), then posts the list.

The key is public by design: /<KEY>.txt at the site root proves the site
sent the list. Never fails the workflow.
"""

from __future__ import annotations

import json
import sys
import time
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET

SITE_URL = "https://edebiyatyarismalari.com"
KEY = "e1be26aa6ab943ebfdf6896613662558"  # as /e1be26aa6ab943ebfdf6896613662558.txt
ENDPOINT = "https://api.indexnow.org/indexnow"
NS = {"s": "http://www.sitemaps.org/schemas/sitemap/0.9"}
MAX_URLS = 10_000  # per request (IndexNow's limit)
LIVE_TIMEOUT = 300  # seconds
POLL_EVERY = 15


def warn(message: str) -> None:
    print(f"::warning::{message}", file=sys.stderr)


def entries(xml: bytes) -> dict[str, str]:
    """<loc> -> <lastmod> ("" when there is none)."""
    root = ET.fromstring(xml)
    return {u.findtext("s:loc", "", NS).strip(): u.findtext("s:lastmod", "", NS).strip()
            for u in root.findall("s:url", NS)}


def fetch(url: str, timeout: int = 30) -> tuple[int, bytes]:
    request = urllib.request.Request(url, headers={"User-Agent": "edebiyatyarismalari-indexnow"})
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            return response.status, response.read()
    except urllib.error.HTTPError as error:
        return error.code, b""


def diff(new_path: str) -> list[str]:
    try:
        status, body = fetch(f"{SITE_URL}/sitemap.xml")
        if status != 200:
            raise OSError(f"HTTP {status}")
        old = entries(body)
    except (OSError, ET.ParseError) as error:
        warn(f"IndexNow: live sitemap unreadable ({error}), nothing listed")
        return []
    with open(new_path, "rb") as f:
        new = entries(f.read())
    changed = [url for url, lastmod in new.items() if old.get(url) != lastmod]
    gone = [url for url in old if url not in new]
    # New first: "send" waits for the first one to be live.
    changed.sort(key=lambda url: url in old)
    urls = changed + gone
    return urls + [f"{SITE_URL}/"] if urls else []


def send(urls: list[str]) -> None:
    if not urls:
        print("IndexNow: nothing changed")
        return
    probe = urls[0]
    deadline = time.monotonic() + LIVE_TIMEOUT
    while fetch(probe, timeout=20)[0] != 200:
        if time.monotonic() > deadline:
            warn(f"IndexNow: {probe} not live after {LIVE_TIMEOUT}s, sending anyway")
            break
        time.sleep(POLL_EVERY)
    host = SITE_URL.split("://", 1)[1]
    for start in range(0, len(urls), MAX_URLS):
        batch = urls[start:start + MAX_URLS]
        body = json.dumps({"host": host, "key": KEY, "keyLocation": f"{SITE_URL}/{KEY}.txt",
                           "urlList": batch}).encode()
        request = urllib.request.Request(ENDPOINT, data=body, method="POST",
                                         headers={"Content-Type": "application/json; charset=utf-8"})
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                print(f"IndexNow: sent {len(batch)} URLs ({response.status})")
        except urllib.error.HTTPError as error:
            warn(f"IndexNow: {error.code} {error.read()[:200]!r}")
        except OSError as error:
            warn(f"IndexNow: {error}")


def main() -> None:
    if len(sys.argv) >= 2 and sys.argv[1] == "diff":
        new_path = sys.argv[sys.argv.index("--new") + 1] if "--new" in sys.argv else "_site/sitemap.xml"
        urls = diff(new_path)
        if urls:  # nothing at all otherwise, so the workflow output stays empty
            print("\n".join(urls))
    elif len(sys.argv) >= 2 and sys.argv[1] == "send":
        send([line.strip() for line in sys.stdin if line.strip()])
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
