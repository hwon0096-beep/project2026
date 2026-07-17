import pandas as pd

# Load the customer file
df = pd.read_csv("customers.csv")

with open("insert_customers.sql", "w", encoding="utf-8") as f:
    for idx, row in df.iterrows():
        # Escape single quotes in city names (e.g., palmeira d'oeste -> palmeira d''oeste)
        cust_id = str(row['customer_id'])
        uniq_id = str(row['customer_unique_id'])
        zip_prefix = str(row['customer_zip_code_prefix'])
        city = str(row['customer_city']).replace("'", "''")
        state = str(row['customer_state'])
        
        sql = f"INSERT INTO customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state) VALUES ('{cust_id}', '{uniq_id}', {zip_prefix}, '{city}', '{state}');\n"
        f.write(sql)
        
    f.write("\nCOMMIT;\n")

print("Success! 'insert_customers.sql' has been created.")