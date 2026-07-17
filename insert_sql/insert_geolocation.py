import pandas as pd

print("Loading and optimizing geolocation data...")
# Load the raw CSV file
df = pd.read_csv("geolocation.csv")

# Clean column headers (removes quotation marks if present)
df.columns = df.columns.str.replace('"', '').str.strip()

# OPTIMIZATION: Drop duplicate entries for the same zip code to save storage space!
df_clean = df.drop_duplicates(subset=['geolocation_zip_code_prefix'])

print(f"Reduced rows from {len(df)} down to {len(df_clean)} unique zip codes.")

with open("insert_geolocation.sql", "w", encoding="utf-8") as f:
    for idx, row in df_clean.iterrows():
        zip_code = str(row['geolocation_zip_code_prefix']).replace('"', '')
        lat = float(row['geolocation_lat'])
        lng = float(row['geolocation_lng'])
        # Escape single quotes in city names (e.g., são paulo -> são paulo)
        city = str(row['geolocation_city']).replace("'", "''")
        state = str(row['geolocation_state'])
        
        sql = f"INSERT INTO geolocation (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state) VALUES ('{zip_code}', {lat}, {lng}, '{city}', '{state}');\n"
        f.write(sql)
        
    f.write("\nCOMMIT;\n")

print("Success! 'insert_geolocation.sql' has been created.")