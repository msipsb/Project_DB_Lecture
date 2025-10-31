import pandas as pd

# Load both files
op = pd.read_csv(r"D:/SIIT/Project_DB_Lecture/order_products_with_review.csv")
orders = pd.read_csv(r"D:/SIIT/Project_DB_Lecture/orders_sampled_filtered.csv")

# Collect all unique order_ids across both files
all_order_ids = pd.concat([op["order_id"], orders["order_id"]]).drop_duplicates().reset_index(drop=True)

# Build mapping: old order_id → new continuous id
order_id_map = {old_id: new_id for new_id, old_id in enumerate(all_order_ids, start=1)}

# Overwrite the original order_id in both DataFrames
op["order_id"] = op["order_id"].map(order_id_map)
orders["order_id"] = orders["order_id"].map(order_id_map)

# Save results (overwriting old order_id with mapped values)
op.to_csv("order_products_with_review_mapped.csv", index=False)
orders.to_csv("orders_sampled_filtered_mapped.csv", index=False)

print("Replaced order_id with continuous values starting from 1 in both files.")