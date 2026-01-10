import os
import re

# Configuration
SHOPS_DIR = r"e:\Things\Personal\SideProject\minecraft-gitops\docker\configs\plugins\EconomyShopGUI\shops"
MULTIPLIER = 3.0
EXCLUDE_FILES = ["content_Protecciones.yml", "Protecciones.yml", "Kits.yml", "ExampleShop.yml"]

def multiply_price(match):
    key = match.group(1)
    value = float(match.group(2))
    new_value = value * MULTIPLIER
    
    # Format: if integer, show as integer. If float, verify if it ends in .0
    if new_value.is_integer():
        return f"{key}: {int(new_value)}"
    else:
        return f"{key}: {new_value:.2f}"

def process_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Regex to capture "buy: 123" or "sell: 45.67"
    # Group 1: key (buy|sell)
    # Group 2: value (number)
    pattern = re.compile(r'(buy|sell):\s*([\d\.]+)')
    
    new_content = pattern.sub(multiply_price, content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Updated: {os.path.basename(file_path)}")

def main():
    if not os.path.exists(SHOPS_DIR):
        print(f"Directory not found: {SHOPS_DIR}")
        return

    for filename in os.listdir(SHOPS_DIR):
        if filename.endswith(".yml") and filename not in EXCLUDE_FILES:
            file_path = os.path.join(SHOPS_DIR, filename)
            process_file(file_path)

if __name__ == "__main__":
    main()
