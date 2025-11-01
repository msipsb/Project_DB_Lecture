import random
from faker import Faker
from datetime import datetime, timedelta

fake = Faker()
random.seed(42)
Faker.seed(42)

reviews = []
for i in range(1, 951):
    rating = random.randint(1, 5)
    review_text = fake.sentence(nb_words=random.randint(5, 15)) if random.random() < 0.8 else 'NULL'
    review_date = datetime.now() - timedelta(days=random.randint(0, 1825))

    row = f"({i}, {rating}, " \
          f"{'NULL' if review_text == 'NULL' else repr(review_text)}, " \
          f"'{review_date.strftime('%Y-%m-%d %H:%M:%S')}')"
    reviews.append(row)

sql = "INSERT INTO review (review_ID, rating, review_text, review_date)\nVALUES\n"
sql += ",\n".join(reviews) + ";"

print(sql)