import pandas as pd

print("Loading and preparing sellers data...")
# Load the CSV file
df = pd.read_csv("sellers.csv")

with open("insert_sellers.sql", "w", encoding="utf-8") as f:
    for idx, row in df.iterrows():
        seller_id = str(row['seller_id'])
        zip_prefix = int(row['seller_zip_code_prefix'])
        
        # Escape single quotes in city names (e.g., miami's hub -> miami''s hub)
        city = str(row['seller_city']).replace("'", "''")
        state = str(row['seller_state'])
        
        sql = f"INSERT INTO sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state) VALUES ('{seller_id}', {zip_prefix}, '{city}', '{state}');\n"
        f.write(sql)
        
    f.write("\nCOMMIT;\n")

print("Success! 'insert_sellers.sql' has been created.")