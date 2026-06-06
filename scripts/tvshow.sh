#!/bin/bash
# Random TV Show — from TVMaze
result=$(curl -s "https://api.tvmaze.com/shows?page=$(( RANDOM % 200 ))")
echo "$result" | python3 -c "
import sys,json,random
shows=json.load(sys.stdin)
if not shows:
    print('📺 *Random TV Show*\n\n_Nothing good on TV today!_')
    sys.exit(0)
s=random.choice(shows)
name=s.get('name','?')
year=(s.get('premiered','') or '')[:4] or '?'
genres=', '.join(s.get('genres',[]) or ['?'])
rating=s.get('rating',{}).get('average') or '?'
summary=(s.get('summary','') or '').replace('<p>','').replace('</p>','').replace('<b>','').replace('</b>','')[:150]
print(f'📺 *Random TV Show*\n')
print(f'**{name}** ({year})')
print(f'Genre: {genres} | Rating: {rating}')
if summary:
    print(f'_{summary}..._')
" 2>/dev/null
