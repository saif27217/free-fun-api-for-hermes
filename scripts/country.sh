#!/bin/bash
# Random Country — from random-data-api.com
# Free, no-auth. https://random-data-api.com
# Fallback: local hardcoded sample if endpoint is unreachable.
python3 - << 'PY'
import sys, json, random, urllib.request
fields = 'name,currency,flag,population,capital'
url = f'https://random-data-api.com/api/nation/random_nation?fields={fields}'
countries = []
try:
    with urllib.request.urlopen(url, timeout=20) as r:
        data = json.loads(r.read().decode('utf-8'))
    if data:
        countries = [data]
except Exception:
    pass
if not countries:
    countries = [
        {'name': 'Canada', 'currency': 'CAD', 'flag': '🇨🇦', 'population': 38005238, 'capital': 'Ottawa'},
        {'name': 'Japan', 'currency': 'JPY', 'flag': '🇯🇵', 'population': 125836000, 'capital': 'Tokyo'},
        {'name': 'Brazil', 'currency': 'BRL', 'flag': '🇧🇷', 'population': 214326223, 'capital': 'Brasília'},
        {'name': 'Kenya', 'currency': 'KES', 'flag': '🇰🇪', 'population': 54027487, 'capital': 'Nairobi'},
        {'name': 'Norway', 'currency': 'NOK', 'flag': '🇳🇴', 'population': 5425270, 'capital': 'Oslo'},
        {'name': 'Australia', 'currency': 'AUD', 'flag': '🇦🇺', 'population': 25687041, 'capital': 'Canberra'},
        {'name': 'Egypt', 'currency': 'EGP', 'flag': '🇪🇬', 'population': 109262178, 'capital': 'Cairo'},
        {'name': 'Mexico', 'currency': 'MXN', 'flag': '🇲🇽', 'population': 128455567, 'capital': 'Mexico City'},
        {'name': 'India', 'currency': 'INR', 'flag': '🇮🇳', 'population': 1428627663, 'capital': 'New Delhi'},
        {'name': 'France', 'currency': 'EUR', 'flag': '🇫🇷', 'population': 68000000, 'capital': 'Paris'},
    ]
c = random.choice(countries)
name = c.get('name') or '?'
currency = c.get('currency') or '?'
flag = c.get('flag') or ''
pop = c.get('population')
pop_s = f'{pop:,}' if isinstance(pop, int) else str(pop or '?')
capital = c.get('capital') or '?'
print('🌍 *Country of the Day*')
print('')
print(f'{flag} **{name}**')
print(f'Capital: {capital} | Population: {pop_s}')
print(f'Currency: {currency}')
PY