import random
from datetime import datetime

# Thai address pool (25 Mueang + 15 non-Mueang) 
    # ... [Insert the full 40-address list from earlier here] ...

thai_addresses = [
    # ✅ 25 Mueang Districts
    {"city": "Mueang Chiang Mai", "province": "Chiang Mai", "street": "Nimmanhaemin Rd", "postal_code": "50200", "country": "Thailand"},
    {"city": "Mueang Nakhon Ratchasima", "province": "Nakhon Ratchasima", "street": "Mittraphap Rd", "postal_code": "30000", "country": "Thailand"},
    {"city": "Mueang Khon Kaen", "province": "Khon Kaen", "street": "Sri Chan Rd", "postal_code": "40000", "country": "Thailand"},
    {"city": "Mueang Phuket", "province": "Phuket", "street": "Yaowarat Rd", "postal_code": "83000", "country": "Thailand"},
    {"city": "Mueang Chonburi", "province": "Chonburi", "street": "Sukhumvit Rd", "postal_code": "20000", "country": "Thailand"},
    {"city": "Mueang Udon Thani", "province": "Udon Thani", "street": "Prajak Rd", "postal_code": "41000", "country": "Thailand"},
    {"city": "Mueang Chiang Rai", "province": "Chiang Rai", "street": "Banpaprakan Rd", "postal_code": "57000", "country": "Thailand"},
    {"city": "Mueang Nakhon Pathom", "province": "Nakhon Pathom", "street": "Phetkasem Rd", "postal_code": "73000", "country": "Thailand"},
    {"city": "Mueang Surat Thani", "province": "Surat Thani", "street": "Talad Mai Rd", "postal_code": "84000", "country": "Thailand"},
    {"city": "Mueang Ayutthaya", "province": "Ayutthaya", "street": "Si Ayutthaya Rd", "postal_code": "13000", "country": "Thailand"},
    {"city": "Mueang Sukhothai", "province": "Sukhothai", "street": "Sukhothai Rd", "postal_code": "64000", "country": "Thailand"},
    {"city": "Mueang Lampang", "province": "Lampang", "street": "Thipchang Rd", "postal_code": "52000", "country": "Thailand"},
    {"city": "Mueang Phitsanulok", "province": "Phitsanulok", "street": "Boromtrailokkanat Rd", "postal_code": "65000", "country": "Thailand"},
    {"city": "Mueang Nakhon Si Thammarat", "province": "Nakhon Si Thammarat", "street": "Ratchadamnoen Rd", "postal_code": "80000", "country": "Thailand"},
    {"city": "Mueang Trang", "province": "Trang", "street": "Ruangrit Rd", "postal_code": "92000", "country": "Thailand"},
    {"city": "Mueang Narathiwat", "province": "Narathiwat", "street": "Narathiwat Rd", "postal_code": "96000", "country": "Thailand"},
    {"city": "Mueang Pattani", "province": "Pattani", "street": "Yarang Rd", "postal_code": "94000", "country": "Thailand"},
    {"city": "Mueang Yala", "province": "Yala", "street": "Siri Rat Rd", "postal_code": "95000", "country": "Thailand"},
    {"city": "Mueang Nakhon Sawan", "province": "Nakhon Sawan", "street": "Sawanvitee Rd", "postal_code": "60000", "country": "Thailand"},
    {"city": "Mueang Ratchaburi", "province": "Ratchaburi", "street": "Phetkasem Rd", "postal_code": "70000", "country": "Thailand"},
    {"city": "Mueang Chanthaburi", "province": "Chanthaburi", "street": "Sukhumvit Rd", "postal_code": "22000", "country": "Thailand"},
    {"city": "Mueang Tak", "province": "Tak", "street": "Intharakiri Rd", "postal_code": "63000", "country": "Thailand"},
    {"city": "Mueang Kalasin", "province": "Kalasin", "street": "Pho Klang Rd", "postal_code": "46000", "country": "Thailand"},
    {"city": "Mueang Kamphaeng Phet", "province": "Kamphaeng Phet", "street": "Ratchadamnoen Rd", "postal_code": "62000", "country": "Thailand"},
    {"city": "Mueang Ubon Ratchathani", "province": "Ubon Ratchathani", "street": "Sapphasit Rd", "postal_code": "34000", "country": "Thailand"},

    # 🔁 15 Non-Mueang Districts
    {"city": "Si Racha", "province": "Chonburi", "street": "Jerm Jom Phon Rd", "postal_code": "20110", "country": "Thailand"},
    {"city": "Bang Pa-in", "province": "Ayutthaya", "street": "U-Thong Rd", "postal_code": "13160", "country": "Thailand"},
    {"city": "Mae Sai", "province": "Chiang Rai", "street": "Phahonyothin Rd", "postal_code": "57130", "country": "Thailand"},
    {"city": "Hang Dong", "province": "Chiang Mai", "street": "Sanpatong Rd", "postal_code": "50230", "country": "Thailand"},
    {"city": "San Sai", "province": "Chiang Mai", "street": "Maejo Rd", "postal_code": "50210", "country": "Thailand"},
    {"city": "Ban Bueng", "province": "Chonburi", "street": "Chonburi-Ban Bueng Rd", "postal_code": "20170", "country": "Thailand"},
    {"city": "Tha Muang", "province": "Kanchanaburi", "street": "Sangchuto Rd", "postal_code": "71110", "country": "Thailand"},
    {"city": "Nang Rong", "province": "Buri Ram", "street": "Chokchai-Dej Udom Rd", "postal_code": "31110", "country": "Thailand"},
    {"city": "Phon", "province": "Khon Kaen", "street": "Phon-Chum Phae Rd", "postal_code": "40120", "country": "Thailand"},
    {"city": "Pak Chong", "province": "Nakhon Ratchasima", "street": "Thanarat Rd", "postal_code": "30130", "country": "Thailand"},
    {"city": "Sattahip", "province": "Chonburi", "street": "Sattahip-Nong Nooch Rd", "postal_code": "20180", "country": "Thailand"},
    {"city": "Ban Pong", "province": "Ratchaburi", "street": "Ban Pong Rd", "postal_code": "70110", "country": "Thailand"},
    {"city": "Phanom Sarakham", "province": "Chachoengsao", "street": "Sarakham Rd", "postal_code": "24120", "country": "Thailand"},
    {"city": "Khlong Luang", "province": "Pathum Thani", "street": "Khlong Luang Rd", "postal_code": "12120", "country": "Thailand"},
    {"city": "Khao Kho", "province": "Phetchabun", "street": "Khao Kho Viewpoint Rd", "postal_code": "67270", "country": "Thailand"}
]


# Generate realistic house numbers
def generate_house_number():
    return str(random.randint(1, 999)) + random.choice(["", "/1", "/2", "/A", "/B"])

# Generate address rows for SQL
def generate_address_rows(num_customers=300, max_addresses_per_customer=3):
    rows = []
    address_id = 1
    for customer_id in range(1, num_customers + 1):
        num_addresses = random.randint(1, max_addresses_per_customer)
        for _ in range(num_addresses):
            addr = random.choice(thai_addresses)
            house_number = generate_house_number()
            row = f"({address_id}, {customer_id}, '{house_number}', '{addr['street']}', '{addr['city']}', '{addr['province']}', '{addr['postal_code']}', '{addr['country']}')"
            rows.append(row)
            address_id += 1
    return rows

# Generate SQL INSERT statement
def generate_sql_insert():
    rows = generate_address_rows()
    sql = "INSERT INTO address (address_ID, customer_ID, house_number, street, city, province, postal_code, country) VALUES\n"
    sql += ",\n".join(rows) + ";"
    return sql

# Output the SQL
print(generate_sql_insert())