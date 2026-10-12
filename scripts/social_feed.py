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
The weekly list gets a card of its own (logo, the week, the contests by
deadline) at images/social/haftalik-<year>-W<week>.jpg.
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
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont

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

# The weekly list's card: the logo's navy and gold on paper white.
LOGO = ROOT / "images" / "edebiyat-yarismalari-logo-icon-512.png"
PAPER, NAVY, GOLD, GREY = (250, 247, 240), (27, 54, 107), (201, 148, 46), (96, 104, 120)
# DejaVu is on the Ubuntu runners, Georgia/Arial for a local preview on Windows.
# Without any of them the weekly list goes out without a card.
FONTS = {
    "serif": ["/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf", "C:/Windows/Fonts/georgiab.ttf"],
    "bold": ["/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", "C:/Windows/Fonts/arialbd.ttf"],
    "regular": ["/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", "C:/Windows/Fonts/arial.ttf"],
}
MONTHS = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım",
          "Aralık"]
DAYS = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"]


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


def font(kind: str, size: int) -> ImageFont.FreeTypeFont | None:
    for path in FONTS[kind]:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return None


def wrap(text: str, face: ImageFont.FreeTypeFont, width: float) -> list[str]:
    lines, line = [], ""
    for word in text.split():
        candidate = f"{line} {word}".strip()
        if line and face.getlength(candidate) > width:
            lines.append(line)
            line = word
        else:
            line = candidate
    return lines + [line] if line else lines


def week_label(monday: dt.date) -> str:
    sunday = monday + dt.timedelta(days=6)
    if monday.month == sunday.month:
        return f"{monday.day}-{sunday.day} {MONTHS[sunday.month - 1]} {sunday.year}"
    return f"{monday.day} {MONTHS[monday.month - 1]} - {sunday.day} {MONTHS[sunday.month - 1]} {sunday.year}"


def list_lines(groups: list[tuple[dt.date, list[str]]], size: int, width: int, limit: int | None = None):
    """(font, text, colour, indent, space before) per line; None when a font is missing."""
    day_face, title_face = font("bold", size), font("regular", size)
    if not day_face or not title_face:
        return None
    lines, shown = [], 0
    for day, titles in groups:
        if limit is not None and shown >= limit:
            break
        lines.append((day_face, f"{day.day} {MONTHS[day.month - 1]} {DAYS[day.weekday()]}", GOLD, 0,
                      size if lines else 0))
        for title in titles:
            if limit is not None and shown >= limit:
                break
            bullet = title_face.getlength("• ")
            for i, part in enumerate(wrap(title, title_face, width - bullet)):
                lines.append((title_face, ("• " if i == 0 else "") + part, NAVY, 0 if i == 0 else bullet,
                              size // 3 if i == 0 else 0))
            shown += 1
    total = sum(len(titles) for _, titles in groups)
    if shown < total:
        lines.append((title_face, f"ve {total - shown} yarışma daha", GREY, 0, size // 2))
    return lines


def weekly_image(this_week: list[dict], monday: dt.date, site: Path) -> str | None:
    """URL of the weekly list's card (written into the site), None without the fonts."""
    w, h = SOCIAL_SIZE
    margin, footer = 80, 120
    title_face, week_face, footer_face = font("serif", 60), font("bold", 40), font("bold", 38)
    if not title_face or not week_face or not footer_face:
        print("weekly card skipped: no font found", file=sys.stderr)
        return None
    canvas = Image.new("RGB", SOCIAL_SIZE, PAPER)
    draw = ImageDraw.Draw(canvas)

    with Image.open(LOGO) as logo:
        logo = logo.convert("RGBA").resize((150, 150), Image.LANCZOS)
        canvas.paste(logo, ((w - logo.width) // 2, 60), logo)
    y = 230
    for line in wrap("Bu hafta son başvurusu olan yarışmalar", title_face, w - 2 * margin):
        draw.text((w / 2, y), line, font=title_face, fill=NAVY, anchor="ma")
        y += 74
    y += 10
    draw.text((w / 2, y), week_label(monday), font=week_face, fill=GOLD, anchor="ma")
    y += 80
    draw.line((w / 2 - 120, y, w / 2 + 120, y), fill=GOLD, width=4)
    y += 50

    groups: dict[dt.date, list[str]] = {}
    for post in this_week:
        groups.setdefault(post["deadline"].date(), []).append(str(post["title"]))
    room = h - footer - 50 - y

    def height(lines):
        return sum(face.size * 1.3 + before for face, _, _, _, before in lines)

    # The largest type that fits; past the smallest, as many contests as fit.
    lines = None
    for size in range(42, 27, -2):
        lines = list_lines(list(groups.items()), size, w - 2 * margin)
        if lines is None or height(lines) <= room:
            break
    else:
        total = len(this_week)
        for limit in range(total - 1, 0, -1):
            lines = list_lines(list(groups.items()), 28, w - 2 * margin, limit)
            if height(lines) <= room:
                break
    if lines is None:
        print("weekly card skipped: no font found", file=sys.stderr)
        return None
    for face, text, colour, indent, before in lines:
        y += before
        draw.text((margin + indent, y), text, font=face, fill=colour)
        y += face.size * 1.3

    draw.rectangle((0, h - footer, w, h), fill=NAVY)
    draw.text((w / 2, h - footer / 2), "edebiyatyarismalari.com", font=footer_face, fill=PAPER, anchor="mm")

    year, week, _ = monday.isocalendar()
    out_relative = f"images/social/haftalik-{year}-W{week:02d}.jpg"
    out_path = site / out_relative
    out_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out_path, "JPEG", quality=90, optimize=True)
    return f"{SITE}/{out_relative}"


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
        weekly = {"id": f"haftalik-{year}-W{week:02d}", "created_at": iso(weekly_at), "publish_at": iso(weekly_at),
                  "text": f"Bu hafta son başvurusu olan yarışmalar\n\n{lines}", "link": SITE + "/", "lang": "tr",
                  "hashtags": BASE_HASHTAGS}
        image = weekly_image(this_week, monday, site)
        if image:
            weekly["image_url"] = image
        items.append(weekly)
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
