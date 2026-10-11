"""Social media feed: _site/social.json plus a JPEG for each listed contest.

Usage (in the Pages workflow, after `jekyll build`):
    python scripts/social_feed.py --site _site

The automatic social media posting reads https://edebiyatyarismalari.com/social.json
(feed format version 1: {"version": 1, "items": [...]}) and posts each item
once. Items:
- a new contest (added in the last NEW_DAYS days),
- a reminder one week before the deadline,
- every Monday, the contests whose deadline falls in that week.
Posts with `hidden: true` are left out.

Instagram takes JPEG only, with an aspect ratio between 4:5 and 1.91:1, and
contest images are WebP posters of any shape. So each listed contest's image
is drawn whole on a 1080x1350 canvas over a blurred copy of itself (nothing
cropped) and saved as <image>-social.jpg next to the original in _site.
Nothing here is committed: the feed and the JPEGs exist only in the build.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import sys
from pathlib import Path

import yaml
from PIL import Image, ImageEnhance, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
SITE = "https://edebiyatyarismalari.com"
# Turkey has been on UTC+3 all year since 2016.
ISTANBUL = dt.timezone(dt.timedelta(hours=3))

NEW_DAYS = 7  # a contest added longer ago than this is no longer "new"
REMINDER_DAYS = 7  # reminder this many days before the deadline
POST_HOUR = 9  # reminders and the weekly list go out at 09:00 Istanbul time
SOCIAL_SIZE = (1080, 1350)
MAX_UPSCALE = 1.5  # small images stay sharp rather than filling the canvas

FILENAME = re.compile(r"^(\d{4})-(\d{2})-(\d{2})-")
BASE_HASHTAGS = ["edebiyat", "yarışma"]


def front_matter(path: Path) -> dict | None:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return None
    parts = text.split("\n---", 1)
    if len(parts) < 2:
        return None
    try:
        data = yaml.safe_load(parts[0][3:])
    except yaml.YAMLError as e:
        print(f"skipping {path}: {e}", file=sys.stderr)
        return None
    return data if isinstance(data, dict) else None


def added_date(path: Path, data: dict) -> dt.date | None:
    """The post's date: front matter `date` if set, else the file name (as Jekyll does)."""
    value = data.get("date")
    if isinstance(value, dt.datetime):
        return value.date()
    if isinstance(value, dt.date):
        return value
    match = FILENAME.match(path.name)
    return dt.date(*map(int, match.groups())) if match else None


def load_posts() -> list[dict]:
    posts = []
    for path in sorted((ROOT / "_posts").rglob("*.md")):
        if not FILENAME.match(path.name):
            continue
        data = front_matter(path)
        if not data or data.get("hidden") or not data.get("permalink") or not data.get("lastDate"):
            continue
        added = added_date(path, data)
        if added is None:
            continue
        posts.append({**data, "added": added, "deadline": dt.datetime.fromtimestamp(int(data["lastDate"]), ISTANBUL)})
    return posts


def at_istanbul(day: dt.date, hour: int = 0) -> dt.datetime:
    return dt.datetime(day.year, day.month, day.day, hour, tzinfo=ISTANBUL)


def iso(moment: dt.datetime) -> str:
    return moment.astimezone(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def url(post: dict) -> str:
    return f"{SITE}/{str(post['permalink']).strip('/')}"


def hashtags(post: dict) -> list[str]:
    # Only the category tags ("hikaye yarışması"); the rest are months, "genel" and the like.
    tags = [t for t in post.get("tags") or [] if isinstance(t, str) and t.strip().endswith("yarışması")]
    seen, out = set(), []
    for tag in BASE_HASHTAGS + tags:
        key = "".join(tag.split()).lower()
        if key not in seen:
            seen.add(key)
            out.append(tag)
    return out[:6]


def details(post: dict, deadline: bool = True) -> str:
    lines = [f"Son başvuru: {post['dateHuman']}"] if deadline and post.get("dateHuman") else []
    if post.get("totalPrize"):
        lines.append(f"Ödül: {post['totalPrize']}")
    return "\n".join(lines)


def social_image(post: dict, site: Path) -> str | None:
    """URL of the contest's JPEG (written into the site), None without a local image."""
    image = str(post.get("image") or "")
    if not image.startswith(SITE + "/images/"):
        return None
    relative = image[len(SITE) + 1:]
    source = ROOT / relative
    if not source.exists():
        return None
    out_relative = str(Path(relative).with_suffix("")) + "-social.jpg"
    out_path = site / out_relative
    if not out_path.exists():
        render(source, out_path)
    return f"{SITE}/{Path(out_relative).as_posix()}"


def render(source: Path, out_path: Path) -> None:
    w, h = SOCIAL_SIZE
    with Image.open(source) as im:
        im = im.convert("RGB")
        cover = max(w / im.width, h / im.height)
        background = im.resize((max(w, round(im.width * cover)), max(h, round(im.height * cover))), Image.LANCZOS)
        left, top = (background.width - w) // 2, (background.height - h) // 2
        background = background.crop((left, top, left + w, top + h)).filter(ImageFilter.GaussianBlur(40))
        canvas = ImageEnhance.Brightness(background).enhance(0.55)
        scale = min(w / im.width, h / im.height, MAX_UPSCALE)
        poster = im.resize((round(im.width * scale), round(im.height * scale)), Image.LANCZOS)
        canvas.paste(poster, ((w - poster.width) // 2, (h - poster.height) // 2))
    out_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out_path, "JPEG", quality=88, optimize=True)


def build(posts: list[dict], site: Path, now: dt.datetime) -> list[dict]:
    items = []
    today = now.astimezone(ISTANBUL).date()
    open_posts = [p for p in posts if p["deadline"] > now]

    for post in open_posts:
        slug = str(post["permalink"]).strip("/")
        added_at = at_istanbul(post["added"])
        reminder_at = at_istanbul(post["deadline"].date() - dt.timedelta(days=REMINDER_DAYS), POST_HOUR)
        is_new = today - post["added"] <= dt.timedelta(days=NEW_DAYS)
        # The reminder is listed from shortly before its time (the poster waits
        # for publish_at) until a day after: later, "one week left" isn't true.
        # A contest added just before its reminder gets only the "new" post.
        wants_reminder = (now - dt.timedelta(days=1) < reminder_at <= now + dt.timedelta(days=2)
                          and reminder_at - added_at > dt.timedelta(days=3))
        if not is_new and not wants_reminder:
            continue
        image = social_image(post, site)
        common = {"link": url(post), "lang": "tr", "hashtags": hashtags(post)}
        if image:
            common["image_url"] = image
        if is_new:
            description = str(post.get("description") or "").strip()
            # Descriptions usually end with the deadline already.
            body = "\n\n".join(part for part in (post["title"], description,
                                                 details(post, "son başvuru" not in description.lower())) if part)
            items.append({"id": f"yeni-{slug}", "created_at": iso(added_at), "text": body, **common})
        if wants_reminder:
            body = "\n\n".join(part for part in (f"Son başvuruya bir hafta kaldı: {post['title']}", details(post))
                               if part)
            items.append({"id": f"hatirlatma-{slug}-{post['deadline'].date()}", "created_at": iso(reminder_at),
                          "publish_at": iso(reminder_at), "text": body, **common})

    monday = today - dt.timedelta(days=today.weekday())
    week_start, week_end = at_istanbul(monday), at_istanbul(monday + dt.timedelta(days=7))
    this_week = sorted((p for p in open_posts if week_start <= p["deadline"] < week_end),
                       key=lambda p: (p["deadline"], p["title"]))
    if this_week:
        year, week, _ = monday.isocalendar()
        lines = "\n".join(f"• {p['title']} ({p.get('dateHuman') or p['deadline'].date()})" for p in this_week)
        weekly_at = at_istanbul(monday, POST_HOUR)
        items.append({"id": f"haftalik-{year}-W{week:02d}", "created_at": iso(weekly_at), "publish_at": iso(weekly_at),
                      "text": f"Bu hafta son başvurusu olan yarışmalar\n\n{lines}", "link": SITE + "/", "lang": "tr",
                      "hashtags": BASE_HASHTAGS})
    return sorted(items, key=lambda i: (i.get("publish_at") or i["created_at"], i["id"]))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--site", type=Path, default=ROOT / "_site")
    parser.add_argument("--now", help="ISO time to build as (testing)")
    args = parser.parse_args()
    now = dt.datetime.fromisoformat(args.now) if args.now else dt.datetime.now(dt.timezone.utc)
    if now.tzinfo is None:
        now = now.replace(tzinfo=dt.timezone.utc)
    items = build(load_posts(), args.site, now)
    args.site.mkdir(parents=True, exist_ok=True)
    (args.site / "social.json").write_text(
        json.dumps({"version": 1, "items": items}, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"social.json: {len(items)} item(s), {sum('image_url' in i for i in items)} with an image")


if __name__ == "__main__":
    main()
