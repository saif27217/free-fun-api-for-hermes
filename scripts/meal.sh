#!/bin/bash
# Random Meal — from TheMealDB
result=$(curl -s "https://www.themealdb.com/api/json/v1/1/random.php")
name=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin)['meals'][0]['strMeal'])" 2>/dev/null)
area=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin)['meals'][0]['strArea'])" 2>/dev/null)
category=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin)['meals'][0]['strCategory'])" 2>/dev/null)
ingredients=$(echo "$result" | python3 -c "
import sys,json
m=json.load(sys.stdin)['meals'][0]
ingredients=[m[f'strIngredient{i}'] for i in range(1,21) if m.get(f'strIngredient{i}')]
print(', '.join(ingredients[:6]))
" 2>/dev/null)

echo "🍽️ *Recipe of the Day*"
echo ""
echo "**$name** — $area ($category)"
echo "_$ingredients_"
