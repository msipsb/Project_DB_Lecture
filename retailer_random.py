import pandas as pd

# Load the CSV
df = pd.read_csv(r'D:/SIIT/Project_DB_Lecture/data_sampled_2/products_filtered_plus500_mapped_with_retailer.csv')

# Extract unique retailer_IDs
retailer_ids = df['retailer_id'].dropna().unique()
retailer_ids = [int(rid) for rid in retailer_ids]

import random
random.seed(42)

sampled_ids = random.sample(retailer_ids, 150)

from faker import Faker
fake = Faker()

rows = []
for rid in sampled_ids:
    status = random.choice(['Active', 'Inactive'])
    account_number = str(random.randint(1000000000, 9999999999))
    account_name = fake.company()
    rows.append(f"({rid}, '{status}', '{account_number}', '{account_name}')")

sql = "INSERT INTO retailer (retailer_id, status, account_number, account_name)\nVALUES\n"
sql += ",\n".join(rows) + ";"

print(sql)