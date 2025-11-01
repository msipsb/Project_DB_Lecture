import pandas as pd
import random
from datetime import datetime, timedelta

# Load invoice data
invoice_df = pd.read_csv(r'D:/SIIT/Project_DB_Lecture/invoice.csv')

# Normalize column names
invoice_df.columns = invoice_df.columns.str.strip().str.lower().str.replace(' ', '_')

# Filter valid order_IDs and invoice_dates
invoice_df = invoice_df.dropna(subset=['order_id', 'invoice_date'])
invoice_df['order_id'] = invoice_df['order_id'].astype(int)
invoice_df['invoice_date'] = pd.to_datetime(invoice_df['invoice_date'])

# Generate delivery records
random.seed(42)
records = []
for i, row in invoice_df.iterrows():
    delivery_id = i + 1
    order_id = row['order_id']
    scheduled_date = row['invoice_date'] + timedelta(days=random.randint(1, 10))
    status = random.choice(['Pending', 'Shipped', 'Delivered', 'Cancelled'])

    actual_delivery_date = ''
    if status == 'Delivered':
        actual_delivery_date = scheduled_date + timedelta(days=random.randint(1, 5))
    elif status == 'Shipped':
        actual_delivery_date = scheduled_date + timedelta(days=random.randint(1, 3))
    elif status == 'Cancelled':
        actual_delivery_date = scheduled_date

    records.append([
        delivery_id,
        order_id,
        scheduled_date.strftime('%Y-%m-%d %H:%M:%S'),
        actual_delivery_date.strftime('%Y-%m-%d %H:%M:%S') if actual_delivery_date else '',
        status
    ])

# Save to CSV
df_out = pd.DataFrame(records, columns=[
    'delivery_ID', 'order_ID', 'scheduled_date', 'actual_delivery_date', 'status'
])
df_out.to_csv('delivery.csv', index=False, encoding='utf-8')