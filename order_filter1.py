import pandas as pd
import numpy as np

# Load the CSV
df = pd.read_csv("D:/SIIT/Project_DB_Lecture/data/orders.csv")

# Define bins for order_hour_of_day
bins = [0, 6, 12, 18, 24]
labels = [0, 1, 2, 3]  # temporary codes for 4 parts

# Temporary grouping
hour_bin = pd.cut(df["order_hour_of_day"], bins=bins, labels=labels, right=False)
dow = df["order_dow"]

# Number of groups and per-group sample size
n_total = 1000
n_groups = 7 * 4  # 28
n_per_group = n_total // n_groups  # ~35

# Stratified sampling
sampled = (
    df.groupby([dow, hour_bin], group_keys=False)
      .apply(lambda x: x.sample(n=min(len(x), n_per_group), random_state=42))
)

# Reassign user_id randomly in range 1–200
sampled["user_id"] = np.random.randint(1, 201, size=len(sampled))

# Rename user_id → customer_id
sampled = sampled.rename(columns={"user_id": "customer_id"})

# Save only the original columns (with renamed column)
sampled = sampled.rename(columns={"user_id": "customer_id"})[df.columns.str.replace("user_id", "customer_id")]
sampled.to_csv("orders_sampled.csv", index=False)

print(f"Created 'orders_sampled.csv' with {len(sampled)} rows, "
      f"customer_id reassigned randomly between 1 and 200.")