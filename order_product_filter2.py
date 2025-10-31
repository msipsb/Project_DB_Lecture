import pandas as pd

# Load files
orders_sampled = pd.read_csv("D:/SIIT/Project_DB_Lecture/orders_sampled.csv")
op_prior = pd.read_csv("D:/SIIT/Project_DB_Lecture/data/order_products__prior.csv")
op_train = pd.read_csv("D:/SIIT/Project_DB_Lecture/data/order_products__train.csv")

# Step 1: combine prior + train
order_products_all = pd.concat([op_prior, op_train], ignore_index=True)

# Step 2: filter combined order_products by sampled order_ids
order_products_filtered = order_products_all[
    order_products_all["order_id"].isin(orders_sampled["order_id"])
]

# Step 3: filter orders_sampled to keep only those present in combined file
orders_sampled_filtered = orders_sampled[
    orders_sampled["order_id"].isin(order_products_filtered["order_id"])
]

# Save results
order_products_filtered.to_csv("order_products_filtered.csv", index=False)
orders_sampled_filtered.to_csv("orders_sampled_filtered.csv", index=False)

print(f"Kept {len(order_products_filtered)} order-product rows "
      f"and {len(orders_sampled_filtered)} sampled orders.")