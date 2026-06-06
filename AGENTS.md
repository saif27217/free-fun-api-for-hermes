# AGENTS.md — Free Fun API for Hermes

> **This file is the single source of truth for any AI agent working with this repo. Read it fully before doing anything.**

## What This Repo Is

A **zero-token cron delivery system** that fetches content from 9 free, no-auth APIs and delivers formatted messages to the user's chat (Telegram/Discord/Slack) on a daily schedule. Each script is a self-contained bash file using `curl` + `python3` (stdlib) for JSON parsing. **No LLM involvement. No API keys. No external dependencies beyond bash + curl + python3.**

## Quick Reference

| Task | Where to look |
|------|---------------|
| Understand the system | This file (AGENTS.md) |
| Add a new API script | `scripts/<name>.sh` — copy an existing script as template |
| Modify cron schedule | The cron job definitions (not in this repo; they live in the user's `cronjob` config) |
| Change output format | Edit the `echo` statements at the bottom of any `scripts/*.sh` |
| Test a script | `bash scripts/<name>.sh` or `./scripts/<name>.sh` |
| Re-deploy after editing | Re-run the `cronjob` create action with the updated script path |

## How The System Works

### The 9 APIs (in delivery order)

| # | Script | API | Time (IST) | UTC Cron |
|---|--------|-----|------------|----------|
| 1 | `joke.sh` | [JokeAPI v2](https://v2.jokeapi.dev) | 8:00 AM | `30 2 * * *` |
| 2 | `fact.sh` | [Useless Facts](https://uselessfacts.jsph.pl) | 8:30 AM | `0 3 * * *` |
| 3 | `bored.sh` | [Bored API](https://bored-api.appbrewery.com) | 9:00 AM | `30 3 * * *` |
| 4 | `advice.sh` | [Advice Slip](https://api.adviceslip.com) | 9:30 AM | `0 4 * * *` |
| 5 | `country.sh` | [REST Countries](https://restcountries.com) | 10:00 AM | `30 4 * * *` |
| 6 | `tvshow.sh` | [TVMaze](https://api.tvmaze.com) | 10:30 AM | `0 5 * * *` |
| 7 | `itunes.sh` | [iTunes Search](https://itunes.apple.com) | 11:00 AM | `30 5 * * *` |
| 8 | `meal.sh` | [TheMealDB](https://www.themealdb.com) | 11:30 AM | `0 6 * * *` |
| 9 | `foodfact.sh` | [Open Food Facts](https://world.openfoodfacts.org) | 12:00 PM | `30 6 * * *` |

### The Pipeline

```
┌──────────────────────────────────────────────────────────┐
│  Hermes cron scheduler (e.g., 30 2 * * *)                │
│  Fires daily at the scheduled UTC time                   │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│  Bash script (e.g., joke.sh)                             │
│  • curl -s "https://api.example.com/..." → JSON         │
│  • python3 -c "import sys,json; print(json.load(sys.stdin)['key'])"  │
│  • echo "formatted output with emojis"                  │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼ stdout (verbatim)
┌──────────────────────────────────────────────────────────┐
│  Hermes delivery system                                  │
│  • Captures script stdout                               │
│  • Sends to user's home channel (Telegram by default)    │
│  • Uses deliver="origin" for current chat, "local" for   │
│    save-only, "all" for fan-out                          │
└──────────────────────────────────────────────────────────┘
```

### Why This Architecture

1. **Zero tokens**: `no_agent: true` flag in cron config skips the LLM entirely
2. **Zero dependencies**: Only `bash`, `curl`, `python3` (with stdlib `json`)
3. **Fast**: Each script runs in <1 second, exits cleanly
4. **Debuggable**: Run any script directly from terminal to see output
5. **Portable**: Drop the scripts on any Linux box with curl + python3

## Script Anatomy

Every script follows the same pattern:

```bash
#!/bin/bash
# <One-line description> — from <API name>
# Free, no-auth. <URL>

# 1. Fetch JSON via curl
result=$(curl -s "https://api.example.com/endpoint")

# 2. Parse with python3 (one-liner per field)
field1=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin)['key'])" 2>/dev/null)

# 3. Format output with echo
echo "🎯 *Title*"
echo ""
echo "$field1"
```

**Conventions:**
- **Error suppression**: All `python3 -c` invocations end with `2>/dev/null` — if parsing fails, the variable is empty
- **Fallbacks**: Critical scripts (like `foodfact.sh`) have fallback data if the API returns nothing
- **Telegram markdown**: Use `*bold*`, `_italic_`, `||spoiler||` for formatting
- **Emoji headers**: Each script starts with a thematic emoji
- **No LLM in the loop**: Don't try to "improve" output by adding `delegate_task` or similar — keep it pure bash

## How to Add a New API Script

1. **Pick an API** from [public-apis](https://github.com/public-apis/public-apis) or any free, no-auth source
2. **Test the endpoint** with `curl -s "<url>" | python3 -m json.tool`
3. **Copy the closest existing script** as a template
4. **Replace the curl URL and JSON keys** with your new API's data
5. **Update the echo statements** with appropriate emoji and formatting
6. **Test it**: `bash scripts/your-new-script.sh`
7. **Add a cron job** via Hermes:
   ```python
   cronjob(
       action="create",
       name="daily-yournew",
       schedule="<UTC cron string>",
       script="/path/to/free-fun-api-for-hermes/scripts/your-new-script.sh",
       no_agent=True,
       deliver="origin",
   )
   ```
8. **Update this AGENTS.md** with the new API in the table

## How to Modify an Existing Script

1. **Edit the script** in `scripts/<name>.sh`
2. **Test it**: `bash scripts/<name>.sh`
3. **The next cron run will pick up the changes automatically** — no need to recreate the cron job

## How to Debug If a Cron Job Stops Working

1. **Run the script manually**: `bash scripts/<name>.sh` — see the actual output
2. **Check the API is still up**: `curl -s "https://api.example.com/endpoint" | head`
3. **Check JSON structure hasn't changed**: API providers occasionally rename fields
4. **Check Hermes cron logs**: Look in `~/.hermes/cron/output/` for execution history
5. **Re-deliver manually if needed**: Just run the script — the stdout is what gets sent

## Cron Job Configuration Reference

When creating cron jobs for these scripts, always use:

| Parameter | Value | Why |
|-----------|-------|-----|
| `no_agent` | `True` | Zero tokens — no LLM in the loop |
| `script` | Full absolute path to `.sh` file | Hermes resolves relative to `~/.hermes/scripts/` by default; absolute path is safer |
| `deliver` | `"origin"` (default), `"local"`, or `"all"` | Controls where the output is sent |
| `schedule` | UTC cron string | IST = UTC+5:30, so 8 AM IST = 2:30 AM UTC |

## Output Format Conventions

- **Header**: `*<Emoji> <Title>*` (bold via Telegram's `*...*` syntax)
- **Body**: Plain text or italicized quotes (`_"text"_`)
- **Spoilers**: `||<content>||` for joke punchlines, movie plots, etc.
- **Bullet lists**: `•` or `-` (avoid pipe tables — Telegram converts them badly)
- **No raw HTML**: Hermes will render markdown, but raw HTML tags from APIs (like TVMaze's `<p>`) get stripped in the script

## API Endpoints Reference

| API | Endpoint | Auth | Notes |
|-----|----------|------|-------|
| JokeAPI v2 | `https://v2.jokeapi.dev/joke/Any?safe-mode` | None | Returns `{setup, delivery}` OR `{joke}` |
| Useless Facts | `https://uselessfacts.jsph.pl/api/v2/facts/random` | None | Returns `{text, source, ...}` |
| Bored API | `https://bored-api.appbrewery.com/random` | None | Returns `{activity, type, participants}` |
| Advice Slip | `https://api.adviceslip.com/advice` | None | Returns `{slip: {advice, id}}` |
| REST Countries | `https://restcountries.com/v3.1/all?fields=name,capital,region,population,flags` | None | Returns array of 250 countries |
| TVMaze | `https://api.tvmaze.com/shows?page=<0-199>` | None | Returns array of 250 shows per page |
| iTunes Search | `https://itunes.apple.com/search?term=<>&entity=song\|movie\|podcast&limit=1` | None | Returns `{results: [...]}` |
| TheMealDB | `https://www.themealdb.com/api/json/v1/1/random.php` | Test key `1` (public, not a secret) | Returns `{meals: [{strMeal, strIngredient1-20, ...}]}` |
| Open Food Facts | `https://world.openfoodfacts.org/api/v2/product/<barcode>.json` | None | Random barcodes in `3017620000000+` range have high hit rate; falls back to `3017620422003` (Nutella) |

## What NOT to Do

- ❌ **Don't add an LLM step to the pipeline** — defeats the zero-token purpose
- ❌ **Don't require API keys** — breaks the "no-auth" guarantee
- ❌ **Don't use heavy dependencies** (jq, node, etc.) — keep it to bash + curl + python3 stdlib
- ❌ **Don't pipe tables** — Telegram renders them badly; use bullets instead
- ❌ **Don't skip error handling** — wrap python3 in `2>/dev/null` and provide fallbacks
- ❌ **Don't forget UTC** — IST is UTC+5:30, so 8 AM IST = 2:30 AM UTC

## Tested Production Date

**2026-06-06** — All 9 scripts were live-tested and verified working in production by Sak.

## Contact

- **Owner**: Sak (saif27217 on GitHub)
- **Use case**: Daily content digest for personal Telegram chat
- **Related projects**: Hermes Agent, n8n workflows, Content River cron
