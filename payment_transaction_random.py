import pandas as pd
import random
from faker import Faker
from datetime import datetime, timedelta

# Load CSVs
order_products_df = pd.read_csv(r'D:/SIIT/Project_DB_Lecture/data_sampled_2/order_products_with_review_mapped_final.csv')
products_df = pd.read_csv(r'D:/SIIT/Project_DB_Lecture/data_sampled_2/products_filtered_plus500_mapped_with_retailer.csv')
invoice_df = pd.read_csv(r'D:/SIIT/Project_DB_Lecture/data_random/invoice.csv')

# Normalize column names
order_products_df.columns = order_products_df.columns.str.strip().str.lower().str.replace(' ', '_')
products_df.columns = products_df.columns.str.strip().str.lower().str.replace(' ', '_')
invoice_df.columns = invoice_df.columns.str.strip().str.lower().str.replace(' ', '_')

# Merge order_products with products to get retailer_id
merged_df = order_products_df.merge(products_df[['product_id', 'retailer_id']], on='product_id', how='inner')
merged_df = merged_df.dropna(subset=['retailer_id'])
merged_df['retailer_id'] = merged_df['retailer_id'].astype(int)

# Merge with invoice to get total_amount
merged_df = merged_df.merge(invoice_df[['order_id', 'total_amount']], on='order_id', how='left')
merged_df = merged_df.dropna(subset=['total_amount'])

# Generate payment_transaction data
fake = Faker()
random.seed(42)
Faker.seed(42)

records = []
payment_id = 1

# Group by order_id
for order_id, group in merged_df.groupby('order_id'):
    total_amount = float(group['total_amount'].iloc[0])
    target_amount = round(total_amount * 0.7, 2)

    num_products = len(group)
    weights = [random.random() for _ in range(num_products)]
    total_weight = sum(weights)
    splits = [(w / total_weight) * target_amount for w in weights]
    splits[-1] = target_amount - sum(splits[:-1])
    splits = [round(x, 2) for x in splits]

    for i, (_, row) in enumerate(group.iterrows()):
        retailer_id = int(row['retailer_id'])
        payment_date = datetime.now() - timedelta(days=random.randint(0, 365))
        status = random.choice(['Successful', 'Failed', 'Pending'])

        records.append([
            payment_id, order_id, retailer_id, splits[i],
            payment_date.strftime('%Y-%m-%d %H:%M:%S'), status
        ])
        payment_id += 1

# Save to CSV
df_out = pd.DataFrame(records, columns=[
    'payment_ID', 'order_ID', 'customer_ID', 'amount',
    'payment_date', 'status'
])
df_out.to_csv(r'D:/SIIT/Project_DB_Lecture/data_random/payment_transaction.csv', index=False, encoding='utf-8')