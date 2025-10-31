import pandas as pd
import numpy as np

# Load the file
products = pd.read_csv(r"D:/SIIT/Project_DB_Lecture/products_filtered_plus500_mapped.csv")

n = len(products)

# Step 1: randomly select 50 distinct numbers from 1–200
chosen_numbers = np.random.choice(range(1, 201), size=50, replace=False)

# Step 2: assign retailer_id
# For each row, flip a coin: either pick from chosen_numbers or from 201–300
# Example: 30% chance from chosen_numbers, 70% from 201–300
prob = 0.3
mask = np.random.rand(n) < prob

retailer_id = np.empty(n, dtype=int)
retailer_id[mask] = np.random.choice(chosen_numbers, size=mask.sum(), replace=True)
retailer_id[~mask] = np.random.randint(201, 301, size=(~mask).sum())

# Step 3: add column
products["retailer_id"] = retailer_id

# Save result
products.to_csv("products_filtered_plus500_mapped_with_retailer.csv", index=False)

print(f"Added retailer_id column: using 50 chosen numbers from 1–200 (reused across rows), "
      f"and 201–300 for the rest.")