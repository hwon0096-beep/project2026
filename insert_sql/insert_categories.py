import pandas as pd

# Load the category file
df = pd.read_csv("category_translation.csv")

with open("insert_categories.sql", "w", encoding="utf-8") as f:
    for idx, row in df.iterrows():
        # Escape any single quotes safely for Oracle SQL
        cat_pt = str(row['product_category_name']).replace("'", "''")
        cat_en = str(row['product_category_name_english']).replace("'", "''")
        
        sql = f"INSERT INTO category_translation (product_category_name, product_category_name_english) VALUES ('{cat_pt}', '{cat_en}');\n"
        f.write(sql)
        
    f.write("\nCOMMIT;\n")

print("Success! 'insert_categories.sql' has been created.")