import pandas as pd
import random
from faker import Faker
from datetime import datetime, timedelta

# Load the orders CSV
orders_df = pd.read_csv(r'D:/SIIT/Project_DB_Lecture/data_sampled_2/orders_sampled_filtered_mapped.csv')

# Normalize column names
orders_df.columns = orders_df.columns.str.strip().str.lower().str.replace(' ', '_')

# Filter valid rows with both order_id and customer_id
orders_df = orders_df.dropna(subset=['order_id', 'customer_id'])
orders_df['order_id'] = orders_df['order_id'].astype(int)
orders_df['customer_id'] = orders_df['customer_id'].astype(int)

# Initialize Faker
fake = Faker()
random.seed(42)
Faker.seed(42)

# Generate invoice data
records = []
for i, row in orders_df.iterrows():
    invoice_id = i + 1
    order_id = row['order_id']
    customer_id = row['customer_id']
    invoice_date = datetime.now() - timedelta(days=random.randint(0, 60))
    due_date = invoice_date + timedelta(days=random.randint(15, 45))
    total_amount = round(random.uniform(500, 10000), 2)
    tax_amount = round(total_amount * 0.07, 2)
    discount_amount = round(random.uniform(0, total_amount * 0.1), 2) if random.random() < 0.5 else 0.0
    status = random.choice(['Paid', 'Unpaid', 'Overdue'])
    created_at = invoice_date
    updated_at = invoice_date + timedelta(days=random.randint(0, 30)) if random.random() < 0.7 else ''
    note = fake.sentence(nb_words=random.randint(5, 12)) if random.random() < 0.5 else ''

    records.append([
        invoice_id, order_id, customer_id,
        invoice_date.strftime('%Y-%m-%d %H:%M:%S'),
        due_date.strftime('%Y-%m-%d %H:%M:%S'),
        total_amount, tax_amount, discount_amount,
        status, created_at.strftime('%Y-%m-%d %H:%M:%S'),
        updated_at if updated_at == '' else updated_at.strftime('%Y-%m-%d %H:%M:%S'),
        note
    ])

# Save to CSV
df_out = pd.DataFrame(records, columns=[
    'invoice_ID', 'order_ID', 'customer_ID', 'invoice_date', 'due_date',
    'total_amount', 'tax_amount', 'discount_amount', 'status',
    'created_at', 'updated_at', 'note'
])
df_out.to_csv('invoice.csv', index=False, encoding='utf-8')