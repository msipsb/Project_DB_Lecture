import pandas as pd

# Load your combined order_products file
df = pd.read_csv("D:/SIIT/Project_DB_Lecture/order_products_filtered.csv")

# Step 1: create a mapping from order_id → sequential review_id
unique_orders = df["order_id"].drop_duplicates().reset_index(drop=True)
order_to_review = {order_id: idx+1 for idx, order_id in enumerate(unique_orders)}

# Step 2: assign review_id based on order_id
df["review_id"] = df["order_id"].map(order_to_review)

# Step 3: reorder columns so review_id is between product_id and add_to_cart_order
cols = list(df.columns)
# find positions
pid_idx = cols.index("product_id")
# rebuild column order
new_cols = cols[:pid_idx+1] + ["review_id"] + cols[pid_idx+1:-1] + [cols[-1]]
df = df[new_cols]

# Save result
df.to_csv("order_products_with_review.csv", index=False)

print("Added review_id column between product_id and add_to_cart_order.")