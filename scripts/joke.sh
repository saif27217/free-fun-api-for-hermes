#!/bin/bash
# Joke of the Day — from JokeAPI v2
result=$(curl -s "https://v2.jokeapi.dev/joke/Any?safe-mode")
setup=$(echo "$result" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('setup',''))" 2>/dev/null)
delivery=$(echo "$result" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('delivery',''))" 2>/dev/null)
joke=$(echo "$result" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('joke',''))" 2>/dev/null)
cat=$(echo "$result" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('category',''))" 2>/dev/null)

echo "😂 *Joke of the Day* [$cat]"
echo ""
if [ -n "$setup" ] && [ -n "$delivery" ]; then
    echo "$setup"
    echo ""
    echo "||$delivery||"
elif [ -n "$joke" ]; then
    echo "$joke"
else
    echo "The joke factory is closed today. Try again tomorrow!"
fi
