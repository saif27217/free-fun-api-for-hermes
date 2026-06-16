#!/bin/bash
# Random Meal — from TheMealDB
python3 - << 'PY'
import sys, json, urllib.request
try:
    with urllib.request.urlopen('https://www.themealdb.com/api/json/v1/1/random.php', timeout=20) as r:
        data = json.loads(r.read().decode('utf-8'))
    meals = data.get('meals') or []
    if not meals:
        raise ValueError('empty meals')
    m = meals[0]
except Exception:
    print('🍽️ *Recipe of the Day*')
    print('')
    print('???\n_Error fetching recipe._')
    sys.exit(0)
name = m.get('strMeal') or '?'
area = m.get('strArea') or '?'
category = m.get('strCategory') or '?'
ingredients = []
for i in range(1, 21):
    ingredient = m.get(f'strIngredient{i}')
    if ingredient:
        ingredients.append(str(ingredient).strip())
    if len(ingredients) == 6:
        break
print('🍽️ *Recipe of the Day*')
print('')
print(f'**{name}** — {area} ({category})')
print(f'_{", ".join(ingredients)}_' if ingredients else '_No ingredients._')
PY