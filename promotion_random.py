import random
from faker import Faker
from datetime import datetime, timedelta

fake = Faker()
random.seed(42)
Faker.seed(42)

# Step 1: Sample 100 distinct product_IDs
product_ids = random.sample(range(1, 5085), 100)

# Step 2: Generate promotion rows
rows = []
for i, pid in enumerate(product_ids):
    code = f"PROMO{i+1:04d}"
    remaining = random.randint(0, 500)
    description = fake.sentence(nb_words=random.randint(5, 12))
    discount_type = random.choice(['Percentage', 'Fixed Amount'])
    discount_value = round(random.uniform(5, 50), 2) if discount_type == 'Fixed Amount' else random.randint(5, 50)
    start_date = datetime.now() - timedelta(days=random.randint(0, 180))
    end_date = start_date + timedelta(days=random.randint(30, 180))

    row = f"('{code}', {pid}, {remaining}, '{description}', '{discount_type}', {discount_value}, " \
          f"'{start_date.strftime('%Y-%m-%d %H:%M:%S')}', '{end_date.strftime('%Y-%m-%d %H:%M:%S')}')"
    rows.append(row)

# Step 3: Build SQL
sql = "INSERT INTO promotion (code, product_ID, remaining, description, discount_type, discount_value, start_date, end_date)\nVALUES\n"
sql += ",\n".join(rows) + ";"

print(sql)