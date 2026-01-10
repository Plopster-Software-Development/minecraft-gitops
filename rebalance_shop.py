import os
import yaml

# Path to shop files
shop_dir = r"e:\Things\Personal\SideProject\minecraft-gitops\docker\configs\plugins\EconomyShopGUI\shops"

# Factors for reduction
# General Blocks/Food/Farming/Decor = divide by 20. (277 -> ~14)
# Spawners/Rares = divide by 100. (300k -> 3k)
# Ores/Valuables = divide by 10. (Diamond 150 -> 15)

def get_divisor(filename):
    if "Spawners" in filename:
        return 100.0
    if "Ores" in filename or "Valuables" in filename:
        return 10.0
    # Default for Blocks, Farming, Decoration, Colored, etc.
    return 20.0

def process_file(filepath, filename):
    with open(filepath, 'r') as f:
        try:
            data = yaml.safe_load(f)
        except yaml.YAMLError as exc:
            print(f"Error reading {filename}: {exc}")
            return

    if not data or 'pages' not in data:
        return

    divisor = get_divisor(filename)
    modified = False

    for page_key, page_val in data['pages'].items():
        if 'items' not in page_val:
            continue
        for item_key, item_val in page_val['items'].items():
            # Adjust 'buy'
            if 'buy' in item_val:
                old_buy = float(item_val['buy'])
                if old_buy > 0:
                    new_buy = round(old_buy / divisor, 2)
                    # Ensure minimum price of 0.1 to avoid 0
                    if new_buy < 0.1: new_buy = 0.1
                    item_val['buy'] = new_buy
                    modified = True
            
            # Adjust 'sell'
            if 'sell' in item_val:
                old_sell = float(item_val['sell'])
                if old_sell > 0:
                    # Sell should be approx 1/4 of buy, but let's just divide the existing sell by same divisor
                    new_sell = round(old_sell / divisor, 2)
                    if new_sell < 0.05: new_sell = 0.05
                    item_val['sell'] = new_sell
                    modified = True

    if modified:
        with open(filepath, 'w') as f:
            yaml.dump(data, f, default_flow_style=False, sort_keys=False)
        print(f"Updated {filename} with divisor {divisor}")

# Iterate over files
for filename in os.listdir(shop_dir):
    if filename.endswith(".yml"):
        process_file(os.path.join(shop_dir, filename), filename)
