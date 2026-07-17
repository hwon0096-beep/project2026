import pandas as pd

print("Loading and preparing order payments data...")
# Load the CSV file
df = pd.read_csv("order_payments.csv")

with open("insert_order_payments.sql", "w", encoding="utf-8") as f:
    for idx, row in df.iterrows():
        order_id = str(row['order_id'])
        seq = int(row['payment_sequential'])
        p_type = str(row['payment_type'])
        installments = int(row['payment_installments'])
        
        # Format payment values to exactly 2 decimal spots
        val = round(float(row['payment_value']), 2)
        inst_group = str(row['installment_group'])
        
        sql = f"INSERT INTO order_payments (order_id, payment_sequential, payment_type, payment_installments, payment_value, installment_group) VALUES ('{order_id}', {seq}, '{p_type}', {installments}, {val}, '{inst_group}');\n"
        f.write(sql)
        
    f.write("\nCOMMIT;\n")

print("Success! 'insert_order_payments.sql' has been created.")