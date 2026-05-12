# Inter-Agro Website — Offline Mirror of geldofpoultry.com

A fully offline, 1:1 static clone of [geldofpoultry.com](https://www.geldofpoultry.com/) that runs on your local machine without any internet connection.

---

## Prerequisites

| Tool | Check | Install |
|------|-------|---------|
| `wget` | `wget --version` | `brew install wget` |
| `python3` | `python3 --version` | ships with macOS |
| `bash` | `bash --version` | ships with macOS |

> `wget` is already installed at `/opt/homebrew/bin/wget` on this machine.

---

## Quick start

```bash
# 1. Mirror the live site (requires internet, ~5–15 min)
bash scripts/mirror.sh

# 2. Scaffold Uzbek and Russian placeholder pages
bash scripts/scaffold-locales.sh

# 3. Serve offline (internet no longer required)
bash serve.sh
```

Then open **<http://localhost:8080/en/>** in your browser.

---

## Directory layout

```
inter-agro-website/
├── site/
│   └── www.geldofpoultry.com/
│       ├── en/          # English (mirrored)
│       ├── fr/          # French  (mirrored)
│       ├── nl/          # Dutch   (mirrored)
│       ├── ar/          # Arabic  (mirrored)
│       ├── uz/          # Uzbek   (scaffolded English copy — translate later)
│       ├── ru/          # Russian (scaffolded English copy — translate later)
│       └── …css/js/images/fonts
├── scripts/
│   ├── mirror.sh            # wget crawl + post-fixup
│   └── scaffold-locales.sh  # build /uz and /ru placeholders
├── serve.sh                 # python3 static server
├── wget-log.txt             # crawl log (created by mirror.sh)
└── README.md
```

---

## Serving on a different port

```bash
bash serve.sh 9000   # serves on http://localhost:9000/en/
```

---

## Known offline limitations

| Feature | Behaviour offline |
|---------|------------------|
| Contact form | Submit silently fails (no server to receive it) |
| Analytics / tracking scripts | Load but can't phone home — inert |
| Social media embeds | May show broken widgets |
| Google Fonts | **Work offline** — fetched during the mirror crawl |
| Language switcher | Works for en / fr / nl / ar / uz / ru |

---

## Refreshing the mirror

Re-run `mirror.sh` at any time to pull changes from the live site. wget's `--mirror` mode uses timestamping so it only re-downloads changed files.

```bash
bash scripts/mirror.sh
```

If you also want to rebuild the Uzbek / Russian scaffolds after a refresh:

```bash
bash scripts/scaffold-locales.sh
```

---

## Troubleshooting

**Some pages look broken (missing CSS/images)**
Check `wget-log.txt` for 404 lines. Re-run `mirror.sh`; wget is idempotent.

**wget returns 403 on certain assets**
The crawl already uses a Chrome user-agent. If a CDN still blocks, add `--limit-rate=200k` inside `mirror.sh` to slow the request rate.

**Language directory missing after mirror**
Run wget again with the specific language entry point:
```bash
wget --mirror --convert-links --adjust-extension --page-requisites \
     --no-check-certificate \
     https://www.geldofpoultry.com/fr/
```
then move the result into `site/www.geldofpoultry.com/`.
