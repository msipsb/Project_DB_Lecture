import random
import csv
from faker import Faker
from datetime import datetime, timedelta

fake = Faker()
random.seed(42)
Faker.seed(42)

# Open CSV file for writing
with open('inventory_record.csv', mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    
    # Write header
    writer.writerow([
        'inventory_ID', 'product_ID', 'quantity_on_hand', 'quantity_reserved',
        'quantity_available', 'reorder_level', 'reorder_quantity',
        'last_restock_date', 'inventory_status', 'lot_number', 'storage_conditions'
    ])
    
    # Write 5084 rows
    for i in range(1, 5085):
        quantity_on_hand = random.randint(0, 500)
        quantity_reserved = random.randint(0, quantity_on_hand)
        quantity_available = quantity_on_hand - quantity_reserved
        reorder_level = random.randint(10, 100)
        reorder_quantity = random.randint(50, 200)
        last_restock_date = (datetime.now() - timedelta(days=random.randint(0, 365))).strftime('%Y-%m-%d %H:%M:%S')
        inventory_status = (
            'Out of Stock' if quantity_on_hand == 0 else
            'backordered' if quantity_available < reorder_level else
            'In Stock'
        )
        lot_number = fake.bothify(text='LOT-#####')
        storage_conditions = random.choice([
            'Cool and dry place', 'Refrigerated', 'Room temperature',
            'Keep away from sunlight', 'Humidity controlled'
        ])
        
        writer.writerow([
            i, i, quantity_on_hand, quantity_reserved, quantity_available,
            reorder_level, reorder_quantity, last_restock_date,
            inventory_status, lot_number, storage_conditions
        ])