import pandas as pd

# Load files
products = pd.read_csv(r"D:/SIIT/Project_DB_Lecture/data/products.csv")
order_products = pd.read_csv(r"D:/SIIT/Project_DB_Lecture/order_products_with_review_mapped.csv")

# Step 1: filter products to only those used in order_products
filtered_products = products[products["product_id"].isin(order_products["product_id"])]

# Step 2: find products not already in filtered set
remaining_products = products[~products["product_id"].isin(filtered_products["product_id"])]

# Step 3: randomly select 500 from remaining (adjust if fewer than 500 available)
extra_products = remaining_products.sample(n=500, random_state=42)

# Step 4: combine filtered + extra
final_products = pd.concat([filtered_products, extra_products], ignore_index=True)

# Step 5: save result
final_products.to_csv("products_filtered_plus500.csv", index=False)

print(f"Created products_filtered_plus500.csv with {len(final_products)} rows "
      f"({len(filtered_products)} filtered + 500 extra unique).")