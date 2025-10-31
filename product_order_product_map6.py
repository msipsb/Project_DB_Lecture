import pandas as pd

# Load both files
products = pd.read_csv(r"D:/SIIT/Project_DB_Lecture/products_filtered_plus500.csv")
order_products = pd.read_csv(r"D:/SIIT/Project_DB_Lecture/order_products_with_review_mapped.csv")

# Collect all unique product_ids across both files
all_product_ids = pd.concat([products["product_id"], order_products["product_id"]]) \
                    .drop_duplicates().reset_index(drop=True)

# Build mapping: old product_id → new continuous id
product_id_map = {old_id: new_id for new_id, old_id in enumerate(all_product_ids, start=1)}

# Overwrite product_id in both DataFrames
products["product_id"] = products["product_id"].map(product_id_map)
order_products["product_id"] = order_products["product_id"].map(product_id_map)

# Save results
products.to_csv("products_filtered_plus500_mapped.csv", index=False)
order_products.to_csv("order_products_with_review_mapped2.csv", index=False)

print("Replaced product_id with continuous values starting from 1 in both files.")