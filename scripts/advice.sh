#!/bin/bash
# Random Advice — from Advice Slip
result=$(curl -s "https://api.adviceslip.com/advice")
advice=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin)['slip']['advice'])" 2>/dev/null)

echo "💡 *Today's Advice*"
echo ""
echo "_\"$advice\"_"
