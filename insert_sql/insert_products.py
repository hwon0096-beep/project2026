import pandas as pd

print("Loading and preparing products data...")
# Load the CSV file
df = pd.read_csv("products.csv")

with open("insert_products.sql", "w", encoding="utf-8") as f:
    for idx, row in df.iterrows():
        prod_id = str(row['product_id'])
        
        # Safely handle missing product categories
        if pd.isna(row['product_category_name']) or str(row['product_category_name']).strip().lower() in ['nan', 'null', '']:
            cat_name = "NULL"
        else:
            cat_name = f"'{str(row['product_category_name']).replace(chr(39), chr(39)+chr(39))}'"
            
        # Helper function to convert numeric columns safely
        def num_val(val):
            if pd.isna(val) or str(val).strip().lower() in ['nan', 'null', '']:
                return "NULL"
            return str(int(float(val))) if float(val).is_integer() else str(float(val))

        name_len = num_val(row['product_name_length'])
        desc_len = num_val(row['product_description_length'])
        photos_qty = num_val(row['product_photos_qty'])
        weight = num_val(row['product_weight_g'])
        length = num_val(row['product_length_cm'])
        height = num_val(row['product_height_cm'])
        width = num_val(row['product_width_cm'])
        
        sql = f"""INSERT INTO products (
            product_id, product_category_name, product_name_length, 
            product_description_length, product_photos_qty, product_weight_g, 
            product_length_cm, product_height_cm, product_width_cm
        ) VALUES (
            '{prod_id}', {cat_name}, {name_len}, 
            {desc_len}, {photos_qty}, {weight}, 
            {length}, {height}, {width}
        );\n"""
        f.write(sql)
        
    f.write("\nCOMMIT;\n")

print("Success! 'insert_products.sql' has been created.")