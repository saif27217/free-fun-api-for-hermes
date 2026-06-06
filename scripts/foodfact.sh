#!/bin/bash
# Random Food Product — from Open Food Facts
# Barcodes start at 3017620422003 — pick random range
barcode=$((3017620000000 + RANDOM * 1000 + RANDOM % 1000))
result=$(curl -s "https://world.openfoodfacts.org/api/v2/product/${barcode}.json")

status=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status_verbose',''))" 2>/dev/null)

if [ "$status" != "product found" ]; then
    # Fallback: use a known working barcode
    result=$(curl -s "https://world.openfoodfacts.org/api/v2/product/3017620422003.json")
fi

name=$(echo "$result" | python3 -c "import sys,json; p=json.load(sys.stdin).get('product',{}); print(p.get('product_name','Unknown') or 'Unknown')" 2>/dev/null)
brand=$(echo "$result" | python3 -c "import sys,json; p=json.load(sys.stdin).get('product',{}); print(p.get('brands','?') or '?')" 2>/dev/null)
cals=$(echo "$result" | python3 -c "import sys,json; p=json.load(sys.stdin).get('product',{}); n=p.get('nutriments',{}); print(n.get('energy-kcal_100g','?'))" 2>/dev/null)

echo "🥗 *Food Fact*"
echo ""
echo "**$name**"
echo "Brand: $brand | $cals kcal/100g"
