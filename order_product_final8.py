import pandas as pd

# Load the file
df = pd.read_csv(r"D:/SIIT/Project_DB_Lecture/order_products_with_review_mapped2.csv")

# Drop the unwanted column if it exists
if "review_id.1" in df.columns:
    df = df.drop(columns=["review_id.1"])

# Save back to the same file (or a new one if you prefer)
df.to_csv(r"D:/SIIT/Project_DB_Lecture/order_products_with_review_mapped_final.csv", index=False)

print("Column 'review_id.1' has been removed.")