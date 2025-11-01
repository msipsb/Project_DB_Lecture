import random
from datetime import datetime, timedelta

random.seed(42)

# Step 1: Generate 200 loyalty_membership entries
tier_levels = ['Bronze', 'Silver', 'Gold']
statuses = ['Active', 'Expired']
customer_ids = random.sample(range(1, 301), 200)

loyalty_rows = []
bronze_rows = []
silver_rows = []
gold_rows = []

for i, customer_id in enumerate(customer_ids):
    membership_id = i + 1
    tier = random.choice(tier_levels)
    points = random.randint(0, 10000)
    enrollment_date = datetime.now() - timedelta(days=random.randint(0, 1825))
    expiration_date = (
        enrollment_date + timedelta(days=random.randint(365, 1825))
        if random.random() < 0.7 else None
    )
    status = 'Expired' if expiration_date and expiration_date < datetime.now() else 'Active'

    loyalty_rows.append(
        f"({membership_id}, {customer_id}, '{tier}', {points}, '{enrollment_date.strftime('%Y-%m-%d %H:%M:%S')}', "
        f"{'NULL' if expiration_date is None else repr(expiration_date.strftime('%Y-%m-%d %H:%M:%S'))}, '{status}')"
    )

    # Step 2: Bronze table (all loyalty_membership entries)
    birthday_point = random.randint(100, 1000)
    bronze_rows.append(f"({membership_id}, {birthday_point})")

# Step 3: Silver table (100 random bronze entries)
silver_ids = random.sample([row.split(",")[0][1:] for row in bronze_rows], 100)
for sid in silver_ids:
    discount = random.randint(5, 30)
    silver_rows.append(f"({sid}, {discount})")

# Step 4: Gold table (50 random silver entries)
gold_ids = random.sample([row.split(",")[0][1:] for row in silver_rows], 50)
gifts = ['Airplane Ticket', 'Gift Card', 'Promotion Code']
for gid in gold_ids:
    gift = random.choice(gifts)
    gold_rows.append(f"({gid}, '{gift}')")

# Final SQL
print("-- loyalty_membership")
print("INSERT INTO loyalty_membership (membership_ID, customer_ID, tier_level, points_balance, enrollment_date, expiration_date, status)\nVALUES")
print(",\n".join(loyalty_rows) + ";")

print("\n-- bronze")
print("INSERT INTO bronze (membership_ID, birthday_point)\nVALUES")
print(",\n".join(bronze_rows) + ";")

print("\n-- silver")
print("INSERT INTO silver (membership_ID, discount_percent)\nVALUES")
print(",\n".join(silver_rows) + ";")

print("\n-- gold")
print("INSERT INTO gold (membership_ID, surprise_gift)\nVALUES")
print(",\n".join(gold_rows) + ";")