#!/bin/bash
# Random iTunes item — music, movie, or podcast
entities=("song" "movie" "podcast")
entity=${entities[$RANDOM % 3]}
terms=("love" "life" "dream" "fire" "star" "blue" "heart" "wild" "dark" "light")
term=${terms[$RANDOM % ${#terms[@]}]}

result=$(curl -s "https://itunes.apple.com/search?term=$term&entity=$entity&limit=1")
name=$(echo "$result" | python3 -c "import sys,json; r=json.load(sys.stdin)['results']; print(r[0].get('trackName',r[0].get('collectionName','?')) if r else '?')" 2>/dev/null)
artist=$(echo "$result" | python3 -c "import sys,json; r=json.load(sys.stdin)['results']; print(r[0].get('artistName','?')) if r else print('?')" 2>/dev/null)

emoji="🎵"
[ "$entity" = "movie" ] && emoji="🎬"
[ "$entity" = "podcast" ] && emoji="🎙️"

echo "$emoji *Random $entity*"
echo ""
echo "**$name**"
echo "by $artist"
