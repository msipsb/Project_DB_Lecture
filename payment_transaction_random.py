import pandas as pd
import random
from faker import Faker
from datetime import datetime, timedelta

# Load CSVs
orders_df = pd.read_csv(r'D:/SIIT/Project_DB_Lecture/data_sampled_2/order_products_with_review_mapped_final.csv')
products_df = pd.read_csv(r'D:/SIIT/Project_DB_Lecture/data_sampled_2/products_filtered_plus500_mapped_with_retailer.csv')

# Normalize column names
orders_df.columns = orders_df.columns.str.strip().str.lower().str.replace(' ', '_')
products_df.columns = products_df.columns.str.strip().str.lower().str.replace(' ', '_')

# Merge to link order_id → product_id → retailer_id
merged_df = orders_df.merge(products_df[['product_id', 'retailer_id']], on='product_id', how='inner')
merged_df = merged_df.dropna(subset=['retailer_id'])
merged_df['retailer_id'] = merged_df['retailer_id'].astype(int)

# Generate payment_transaction data
fake = Faker()
random.seed(42)
Faker.seed(42)

records = []
for i, row in merged_df.iterrows():
    payment_id = i + 1
    order_id = int(row['order_id'])
    customer_id = int(row['retailer_id'])
    payment_method = random.choice(['Credit Card', 'Debit Card', 'PayPal', 'Bank Transfer'])
    amount = round(random.uniform(100, 5000), 2)
    currency = random.choice(['USD', 'THB', 'EUR', 'JPY'])
    payment_date = datetime.now() - timedelta(days=random.randint(0, 365))
    status = random.choice(['Successful', 'Failed', 'Pending'])

    records.append([
        payment_id, order_id, customer_id, payment_method,
        amount, currency, payment_date.strftime('%Y-%m-%d %H:%M:%S'), status
    ])

# Save to CSV
df_out = pd.DataFrame(records, columns=[
    'payment_ID', 'order_ID', 'customer_ID', 'payment_method',
    'amount', 'currency', 'payment_date', 'status'
])
df_out.to_csv('payment_transaction.csv', index=False, encoding='utf-8')