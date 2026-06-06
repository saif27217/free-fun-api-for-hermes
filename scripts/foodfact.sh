#!/bin/bash
# Random Food Product — from Open Food Facts (curated barcode list)
# Free, no-auth. https://world.openfoodfacts.org
# Product-by-barcode lookup. Random EAN-13 generation hits <1% success
# rate because most random codes don't exist in OFF. Instead we maintain
# a curated list of 15 verified popular products and pick from that.
# Each cron tick makes exactly 1 API call to stay under OFF's rate limit.

# Curated list of 15 verified barcodes across categories.
barcodes=(
  "3017620422003"   # Nutella (Italy, Ferrero)
  "3046920022651"   # Lindt Excellence 70% Dark Chocolate
  "8000500037560"   # Kinder Bueno
  "8000500310427"   # Nutella Biscuits
  "7613034626844"   # Chocapic Cereal (Nestlé)
  "7622210449283"   # Prince Petit Beurre Chocolat (Mondelez)
  "7622210411587"   # Oreo Original
  "3228857000852"   # Harrys Pain de Mie 100% Mie Nature
  "3175680011480"   # Gerblé Sésame Biscuits
  "5000159461122"   # Snickers Bar
  "5000159459228"   # Twix Twin
  "5449000000996"   # Coca-Cola Original Taste
  "5449000131805"   # Coca-Cola Zero
  "5449000133335"   # Coca-Cola Zero Sugar
  "5449000050205"   # Coca-Cola Light
)

# Pick a random barcode
barcode=${barcodes[$RANDOM % ${#barcodes[@]}]}

# Single API call
result=$(curl -s -m 15 "https://world.openfoodfacts.org/api/v2/product/${barcode}.json")

# Parse and format — handle multiple energy key variants
echo "$result" | python3 << 'PYEOF'
import sys, json
try:
    d = json.load(sys.stdin)
except Exception:
    print('🥗 *Food Fact*')
    print('')
    print('Open Food Facts is taking a break. Try again tomorrow!')
    sys.exit(0)

if d.get('status') != 1:
    print('🥗 *Food Fact*')
    print('')
    print('Product not available. Try again tomorrow!')
    sys.exit(0)

p = d.get('product', {})
name = (p.get('product_name') or 'Unknown').strip()
brand = (p.get('brands') or '?').strip() or '?'
n = p.get('nutriments', {})

def get_fallback(d, keys):
    """Get first non-empty value from a list of candidate keys."""
    for k in keys:
        v = d.get(k)
        if v is not None and v != '':
            return v
    return None

# Try multiple energy key variants
cals = get_fallback(n, ['energy-kcal_100g', 'energy-kcal', 'energy-kcal_prepared_100g', 'energy-kcal_prepared'])
sugar = get_fallback(n, ['sugars_100g', 'sugars'])
fat = get_fallback(n, ['fat_100g', 'fat'])
protein = get_fallback(n, ['proteins_100g', 'proteins'])
salt = get_fallback(n, ['salt_100g', 'salt'])

def fmt(v, unit=''):
    if v is None:
        return '?'
    try:
        fv = float(v)
        if fv == int(fv):
            return f'{int(fv)}{unit}'
        return f'{fv:.1f}{unit}'
    except (TypeError, ValueError):
        return f'{v}{unit}' if v else '?'

print('🥗 *Food Fact*')
print('')
print(f'**{name}**')
print(f'Brand: {brand}')
print('')
print('Per 100g:')
print(f'  • Calories: {fmt(cals)} kcal')
print(f'  • Sugar: {fmt(sugar, " g")}')
print(f'  • Fat: {fmt(fat, " g")}')
print(f'  • Protein: {fmt(protein, " g")}')
print(f'  • Salt: {fmt(salt, " g")}')
PYEOF
