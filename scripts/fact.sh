#!/bin/bash
# Random Fact — from Useless Facts API
result=$(curl -s "https://uselessfacts.jsph.pl/api/v2/facts/random")
fact=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin)['text'])" 2>/dev/null)

echo "📚 *Random Fact*"
echo ""
echo "$fact"
