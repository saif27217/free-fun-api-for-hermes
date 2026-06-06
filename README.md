# 🎉 Free Fun API for Hermes

A curated collection of **9 free, no-auth APIs** that deliver daily fun content (jokes, facts, recipes, entertainment, food data) directly to your chat via **zero-token cron jobs**. Built for [Hermes Agent](https://github.com/NousResearch/hermes-agent).

## ✨ What This Does

Every morning, you get 9 lightweight pings spread between 8 AM and 12 PM IST — jokes to start your day, recipes for lunch ideas, food facts for nutrition research, and entertainment picks for the evening. All delivered by a single curl + bash + python3 pipeline. **Zero LLM tokens. Zero API keys. Zero cost.**

## 🎯 The 9 APIs

| # | Time (IST) | API | What It Does | Endpoint |
|---|------------|-----|--------------|----------|
| 1 | 8:00 AM | 😂 **Joke** | Two-part or single-line jokes | `v2.jokeapi.dev` |
| 2 | 8:30 AM | 📚 **Fact** | Random useless-but-fun facts | `uselessfacts.jsph.pl` |
| 3 | 9:00 AM | 🎯 **Bored** | Activity suggestions | `bored-api.appbrewery.com` |
| 4 | 9:30 AM | 💡 **Advice** | One-line life advice | `api.adviceslip.com` |
| 5 | 10:00 AM | 🌍 **Country** | Random country card | `restcountries.com` |
| 6 | 10:30 AM | 📺 **TV Show** | Random show with rating | `api.tvmaze.com` |
| 7 | 11:00 AM | 🎵 **iTunes** | Random song/movie/podcast | `itunes.apple.com` |
| 8 | 11:30 AM | 🍽️ **Meal** | Recipe with ingredients | `themealdb.com` |
| 9 | 12:00 PM | 🥗 **Food Fact** | Product nutrition data | `world.openfoodfacts.org` |

## 🚀 Quick Start (Hermes)

### 1. Clone the repo

```bash
git clone https://github.com/saif27217/free-fun-api-for-hermes.git
cd free-fun-api-for-hermes
chmod +x scripts/*.sh
```

### 2. Test a script

```bash
./scripts/joke.sh
./scripts/fact.sh
./scripts/meal.sh
```

### 3. Install as cron jobs (zero-token, `no_agent: true`)

```python
for script, time_utc in [
    ("joke.sh",    "30 2 * * *"),  # 8:00 AM IST
    ("fact.sh",    "0 3 * * *"),   # 8:30 AM IST
    ("bored.sh",   "30 3 * * *"),  # 9:00 AM IST
    ("advice.sh",  "0 4 * * *"),   # 9:30 AM IST
    ("country.sh", "30 4 * * *"),  # 10:00 AM IST
    ("tvshow.sh",  "0 5 * * *"),   # 10:30 AM IST
    ("itunes.sh",  "30 5 * * *"),  # 11:00 AM IST
    ("meal.sh",    "0 6 * * *"),   # 11:30 AM IST
    ("foodfact.sh","30 6 * * *"),  # 12:00 PM IST
]:
    cronjob(
        action="create",
        name=f"daily-{script.replace('.sh','')}",
        schedule=time_utc,
        script=f"/home/sak/free-fun-api-for-hermes/scripts/{script}",
        no_agent=True,       # ← no LLM, zero tokens
        deliver="origin",    # ← deliver to current chat
    )
```

Each cron job runs the script, captures stdout, and delivers it verbatim to your chat. No AI in the loop.

## 💰 Resource Cost

- **Tokens**: 0 per day (no LLM)
- **CPU**: <1 second total per day
- **RAM**: Negligible (each script runs ~0.1s, exits)
- **Disk**: ~2KB total for all scripts
- **API rate limits**: All APIs are free tier with generous limits; staggered schedule avoids bursts

## 🛠️ Architecture

```
┌─────────────────┐
│  cron schedule  │  (e.g., 0 8 * * *)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   bash script   │  (joke.sh)
│   curl + jq     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   stdout text   │  ← delivered verbatim
└─────────────────┘
```

**No agent loop. No LLM. No context window. Just a pipe.**

## 📂 Repo Structure

```
free-fun-api-for-hermes/
├── README.md              # This file
├── AGENTS.md              # How AI agents should use this repo
├── scripts/
│   ├── joke.sh            # JokeAPI v2
│   ├── fact.sh            # Useless Facts
│   ├── bored.sh           # Bored API
│   ├── advice.sh          # Advice Slip
│   ├── country.sh         # REST Countries
│   ├── tvshow.sh          # TVMaze
│   ├── itunes.sh          # iTunes Search
│   ├── meal.sh            # TheMealDB
│   └── foodfact.sh        # Open Food Facts
└── examples/
    └── cron-config.yaml   # Sample cron job config
```

## 🎨 Sample Outputs

**Joke:**
```
😂 Joke of the Day [Programming]
Why did the programmer jump on the table?
||Because debug was on his screen.||
```

**Country:**
```
🌍 Country of the Day
Saint Lucia — Americas
Capital: Castries | Population: 184,100
```

**Meal:**
```
🍽️ Recipe of the Day
Summer Pistou — France (Vegetarian)
Leek, Onion, Olive Oil, Runner Beans, Cannellini Beans, Spinach
```

## 🧪 Tested & Working

All 9 APIs were live-tested in production on **2026-06-06**. Each script:
- Returns valid JSON
- Parses gracefully on errors
- Falls back to known-working data if API returns empty
- Outputs Telegram-flavored markdown (emoji headers, spoiler tags for punchlines)

## 📜 License

MIT — fork, modify, and ship your own daily digest.

---

**Built by Sak** · Powered by Hermes Agent · [Source repo](https://github.com/saif27217/free-fun-api-for-hermes)
