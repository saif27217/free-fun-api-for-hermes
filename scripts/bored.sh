#!/bin/bash
# Random Activity — from Bored API
result=$(curl -s "https://bored-api.appbrewery.com/random")
activity=$(echo "$result" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['activity'])" 2>/dev/null)
ptype=$(echo "$result" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['type'])" 2>/dev/null)
participants=$(echo "$result" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['participants'])" 2>/dev/null)

echo "🎯 *Bored? Try This*"
echo ""
echo "$activity"
echo ""
echo "_Type: $ptype | Participants: $participants_"
