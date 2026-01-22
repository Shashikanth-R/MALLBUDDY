import requests
import json
import re

# Mocking the frontend logic in Python

def load_layout():
    with open('frontend/floor-layouts.js', 'r', encoding='utf-8') as f:
        content = f.read()
        # Extract the JSON-like object string
        match = re.search(r'const FLOOR_LAYOUTS = ({[\s\S]*?});', content)
        if match:
            # This is a bit hacky because it's JS not strict JSON (keys not quoted sometimes)
            # But the provided file has quoted keys "1": { ... }
            # Let's try to convert it to valid JSON
            js_obj = match.group(1)
            # Remove comments
            js_obj = re.sub(r'//.*', '', js_obj)
            # Quote unquoted keys (simple regex, might not be perfect but works for this file)
            # Actually keys are already quoted in the file "1", "name", etc. except inside arrays maybe?
            # Let's manual parse or use a library if needed, but for now let's just inspect specific units
            return js_obj
    return None

def fetch_stores():
    try:
        response = requests.get('http://localhost:5000/api/admin/stores')
        if response.status_code == 200:
            return response.json()['stores']
    except Exception as e:
        print(f"Error fetching stores: {e}")
    return []

def verify():
    print("Fetching live stores...")
    live_stores = fetch_stores()
    print(f"Found {len(live_stores)} stores in DB.")
    
    # Check specific units known to be in layout
    test_units = ['105', '110', '115', '205', '301', '401']
    
    print("\nVerifying Store <-> Unit mapping:")
    for unit in test_units:
        # Find in DB
        db_store = next((s for s in live_stores if s['unit'] == unit), None)
        
        if db_store:
            print(f"[Unit {unit}] DB: {db_store['name']} ({db_store['status']})")
        else:
            print(f"[Unit {unit}] DB: <VACANT>")

    print("\nIf you see expected store names above, the map will render them correctly.")

if __name__ == '__main__':
    verify()
