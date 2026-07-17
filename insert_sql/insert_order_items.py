import pandas as pd

print("Loading and preparing order items data...")
# Load the CSV file
df = pd.read_csv("order_items.csv")

with open("insert_order_items.sql", "w", encoding="utf-8") as f:
    # Adjust session timestamps to match your data formatting
    f.write("ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS';\n\n")
    
    for idx, row in df.iterrows():
        order_id = str(row['order_id'])
        item_id = int(row['order_item_id'])
        product_id = str(row['product_id'])
        seller_id = str(row['seller_id'])
        ship_limit = str(row['shipping_limit_date'])
        
        # Round prices to exactly 2 decimal places to clean up long fractions
        price = round(float(row['price']), 2)
        freight = round(float(row['freight_value']), 2)
        total = round(float(row['total_item_value']), 2)
        
        sql = f"""INSERT INTO order_items (
            order_id, order_item_id, product_id, seller_id, 
            shipping_limit_date, price, freight_value, total_item_value
        ) VALUES (
            '{order_id}', {item_id}, '{product_id}', '{seller_id}', 
            TO_TIMESTAMP('{ship_limit}'), {price}, {freight}, {total}
        );\n"""
        f.write(sql)
        
    f.write("\nCOMMIT;\n")

print("Success! 'insert_order_items.sql' has been created.")