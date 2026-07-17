import pandas as pd

# 1. Load your local CSV file
df = pd.read_csv("orders.csv")

# 2. Open a new SQL file to write the script into
with open("insert_orders.sql", "w", encoding="utf-8") as f:
    # Set the session format at the very top so Oracle doesn't throw month errors
    f.write("ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';\n")
    f.write("ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS';\n")
    f.write("ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = 'YYYY-MM-DD HH24:MI:SS';\n\n")
    
    # 3. Loop through the rows and format the SQL statements
    for idx, row in df.iterrows():
        # Handle empty/null values gracefully for database insertion
        def sql_val(val, is_str=False):
            if pd.isna(val) or str(val).strip().lower() in ['nan', 'null', '']:
                return "NULL"
            return f"'{str(val).replace(chr(39), chr(39)+chr(39))}'" if is_str else str(val)

        sql = f"""INSERT INTO ORDERS (
            ORDER_ID, CUSTOMER_ID, ORDER_STATUS, 
            ORDER_PURCHASE_TIMESTAMP, ORDER_APPROVED_AT, 
            ORDER_DELIVERED_CARRIER_DATE, ORDER_DELIVERED_CUSTOMER_DATE, 
            ORDER_ESTIMATED_DELIVERY_DATE, DELIVERY_DAYS, 
            APPROVAL_HOURS, DELIVERY_DELAY_DAYS
        ) VALUES (
            {sql_val(row['order_id'], True)}, 
            {sql_val(row['customer_id'], True)}, 
            {sql_val(row['order_status'], True)}, 
            TO_TIMESTAMP({sql_val(row['order_purchase_timestamp'], True)}), 
            TO_TIMESTAMP({sql_val(row['order_approved_at'], True)}), 
            TO_TIMESTAMP({sql_val(row['order_delivered_carrier_date'], True)}), 
            TO_TIMESTAMP({sql_val(row['order_delivered_customer_date'], True)}), 
            TO_DATE({sql_val(row['order_estimated_delivery_date'], True)}), 
            {sql_val(row['delivery_days'])}, 
            {sql_val(row['approval_hours'])}, 
            {sql_val(row['delivery_delay_days'])}
        );\n"""
        f.write(sql)
        
    # 4. Add the final commit automatically at the very bottom
    f.write("\nCOMMIT;\n")

print("Success! 'insert_orders.sql' has been created.")