import pandas as pd

print("Loading and parsing order reviews...")
# Load the CSV file
df = pd.read_csv("order_reviews.csv")

with open("insert_order_reviews.sql", "w", encoding="utf-8") as f:
    # Handle the date and timestamp session logic first
    f.write("ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS';\n\n")
    
    for idx, row in df.iterrows():
        review_id = str(row['review_id'])
        order_id = str(row['order_id'])
        score = int(row['review_score'])
        
        # Clean up text strings and safely handle empty comment blocks
        def text_val(val):
            if pd.isna(val) or str(val).strip().lower() in ['nan', 'null', '']:
                return "NULL"
            # Escape single quotes (e.g., não -> não, but internal quotes get doubled)
            escaped = str(val).replace("'", "''")
            return f"'{escaped}'"

        title = text_val(row['review_comment_title'])
        message = text_val(row['review_comment_message'])
        
        # Handle the dates smoothly
        created = text_val(row['review_creation_date'])
        answered = text_val(row['review_answer_timestamp'])
        
        # Convert literal 'True'/'False' words into matching strings for the schema
        has_title = f"'{str(row['has_title'])}'"
        has_comment = f"'{str(row['has_comment'])}'"
        
        # Use TO_TIMESTAMP only if the field contains a valid date string
        created_clause = f"TO_TIMESTAMP({created})" if created != "NULL" else "NULL"
        answered_clause = f"TO_TIMESTAMP({answered})" if answered != "NULL" else "NULL"

        sql = f"""INSERT INTO order_reviews (
            review_id, order_id, review_score, review_comment_title, 
            review_comment_message, review_creation_date, review_answer_timestamp, 
            has_title, has_comment
        ) VALUES (
            '{review_id}', '{order_id}', {score}, {title}, 
            {message}, {created_clause}, {answered_clause}, 
            {has_title}, {has_comment}
        );\n"""
        f.write(sql)
        
    f.write("\nCOMMIT;\n")

print("Success! 'insert_order_reviews.sql' has been created.")