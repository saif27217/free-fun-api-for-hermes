#!/bin/bash
# Random Food Product — from Open Food Facts
# Free, no-auth. https://world.openfoodfacts.org
python3 - << 'PY'
import sys, json, random, urllib.request
barcodes = [
    "3017620422003", "3046920022651", "8000500037560", "8000500310427",
    "7613034626844", "7622210449283", "7622210411587", "3228857000852",
    "3175680011480", "5000159461122", "5000159459228", "5449000000996",
    "5449000131805", "5449000133335", "5449000050205",
]
barcode = random.choice(barcodes)
url = "https://world.openfoodfacts.org/api/v2/product/" + barcode + ".json"
try:
    with urllib.request.urlopen(url, timeout=20) as r:
        d = json.loads(r.read().decode("utf-8"))
except Exception:
    print("🥗 *Food Fact*")
    print("")
    print("Open Food Facts is taking a break. Try again tomorrow!")
    sys.exit(0)

if d.get("status") != 1:
    print("🥗 *Food Fact*")
    print("")
    print("Open Food Facts is taking a break. Try again tomorrow!")
    sys.exit(0)

p = d.get("product", {})
name = (p.get("product_name") or "Unknown").strip()
brand = (p.get("brands") or "?").strip() or "?"
n = p.get("nutriments", {})

def get_fallback(d, keys):
    for k in keys:
        v = d.get(k)
        if v is not None and v != "":
            return v
    return None

cals = get_fallback(n, ["energy-kcal_100g", "energy-kcal", "energy-kcal_prepared_100g", "energy-kcal_prepared"])
sugar = get_fallback(n, ["sugars_100g", "sugars"])
fat = get_fallback(n, ["fat_100g", "fat"])
protein = get_fallback(n, ["proteins_100g", "proteins"])
salt = get_fallback(n, ["salt_100g", "salt"])

def fmt(v, unit=""):
    if v is None:
        return "?"
    try:
        fv = float(v)
        if fv == int(fv):
            return str(int(fv)) + unit
        return "{:.1f}".format(fv) + unit
    except (TypeError, ValueError):
        return (str(v) + unit) if v else "?"

print("🥗 *Food Fact*")
print("")
print("**" + name + "**")
print("Brand: " + brand)
print("")
print("Per 100g:")
print("  • Calories: " + fmt(cals) + " kcal")
print("  • Sugar: " + fmt(sugar, " g"))
print("  • Fat: " + fmt(fat, " g"))
print("  • Protein: " + fmt(protein, " g"))
print("  • Salt: " + fmt(salt, " g"))
PY