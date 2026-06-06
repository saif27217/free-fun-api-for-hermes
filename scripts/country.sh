#!/bin/bash
# Random Country — from REST Countries
result=$(curl -s "https://restcountries.com/v3.1/all?fields=name,capital,region,population,flags")
count=$(echo "$result" | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d))" 2>/dev/null)
idx=$(( RANDOM % count ))
country=$(echo "$result" | python3 -c "import sys,json,random; random.seed(); d=json.load(sys.stdin); c=d[$idx]; print(f\"{c['name']['common']}|{c.get('region','?')}|{c.get('population',0):,}|{','.join(c.get('capital',['?']))}|{c['flags']['png']}\")" 2>/dev/null)

IFS='|' read -r name region pop capital flag <<< "$country"
echo "🌍 *Country of the Day*"
echo ""
echo "**$name** — $region"
echo "Capital: $capital | Population: $pop"
