from faker import Faker
import random

fake = Faker()
Faker.seed(42)
random.seed(42)

genders = ['Male', 'Female', 'Other', 'Preferred not to say']
nationalities = [
    "Afghan", "Albanian", "Algerian", "American", "Andorran", "Angolan",
    "Argentine", "Armenian", "Australian", "Austrian", "Azerbaijani",
    "Bahamian", "Bahraini", "Bangladeshi", "Barbadian", "Belarusian",
    "Belgian", "Belizean", "Beninese", "Bhutanese", "Bolivian",
    "Bosnian", "Brazilian", "British", "Bruneian", "Bulgarian",
    "Burkinabé", "Burmese", "Burundian", "Cambodian", "Cameroonian",
    "Canadian", "Cape Verdean", "Central African", "Chadian", "Chilean",
    "Chinese", "Colombian", "Comorian", "Congolese", "Costa Rican",
    "Croatian", "Cuban", "Cypriot", "Czech", "Danish", "Djiboutian",
    "Dominican", "Dutch", "East Timorese", "Ecuadorian", "Egyptian",
    "Emirati", "English", "Equatorial Guinean", "Eritrean", "Estonian",
    "Ethiopian", "Fijian", "Filipino", "Finnish", "French", "Gabonese",
    "Gambian", "Georgian", "German", "Ghanaian", "Greek", "Grenadian",
    "Guatemalan", "Guinean", "Guyanese", "Haitian", "Honduran",
    "Hungarian", "Icelandic", "Indian", "Indonesian", "Iranian",
    "Iraqi", "Irish", "Israeli", "Italian", "Ivorian", "Jamaican",
    "Japanese", "Jordanian", "Kazakhstani", "Kenyan", "Korean",
    "Kuwaiti", "Kyrgyzstani", "Laotian", "Latvian", "Lebanese",
    "Liberian", "Libyan", "Lithuanian", "Luxembourgish", "Macedonian",
    "Malagasy", "Malawian", "Malaysian", "Maldivian", "Malian",
    "Maltese", "Marshallese", "Mauritanian", "Mauritian", "Mexican",
    "Micronesian", "Moldovan", "Monegasque", "Mongolian", "Montenegrin",
    "Moroccan", "Mozambican", "Namibian", "Nepalese", "New Zealander",
    "Nicaraguan", "Nigerian", "Nigerien", "Norwegian", "Omani",
    "Pakistani", "Palauan", "Palestinian", "Panamanian",
    "Papua New Guinean", "Paraguayan", "Peruvian", "Polish",
    "Portuguese", "Qatari", "Romanian", "Russian", "Rwandan",
    "Salvadoran", "Samoan", "San Marinese", "São Toméan",
    "Saudi Arabian", "Scottish", "Senegalese", "Serbian", "Seychellois",
    "Sierra Leonean", "Singaporean", "Slovak", "Slovenian",
    "Solomon Islander", "Somali", "South African", "Spanish",
    "Sri Lankan", "Sudanese", "Surinamese", "Swazi", "Swedish",
    "Swiss", "Syrian", "Taiwanese", "Tajikistani", "Tanzanian", "Thai",
    "Togolese", "Tongan", "Trinidadian", "Tunisian", "Turkish",
    "Turkmen", "Tuvaluan", "Ugandan", "Ukrainian", "Uruguayan",
    "Uzbekistani", "Venezuelan", "Vietnamese", "Welsh", "Yemeni",
    "Zambian", "Zimbabwean"
]

rows = []
for i in range(300):
    first_name = fake.first_name()
    middle_name = fake.first_name() if random.random() < 0.3 else None
    last_name = fake.last_name()
    email = f"{first_name.lower()}.{last_name.lower()}{i}@example.com"
    phone_number = fake.msisdn()[:11]
    date_of_birth = fake.date_of_birth(minimum_age=18, maximum_age=80)
    gender = random.choice(genders)
    registration_date = fake.date_time_between(start_date="-5y", end_date="now")
    last_login_date = (
    fake.date_time_between(start_date=registration_date, end_date="now").strftime("%Y-%m-%d %H:%M:%S")
    if random.random() < 0.8 else None
)
    nationality = random.choice(nationalities)

    row = f"('{first_name}', " \
      f"{'NULL' if middle_name is None else repr(middle_name)}, " \
      f"'{last_name}', '{email}', '{phone_number}', '{date_of_birth}', " \
      f"'{gender}', '{registration_date.strftime('%Y-%m-%d %H:%M:%S')}', " \
      f"{'NULL' if last_login_date is None else repr(last_login_date)}, " \
      f"'{nationality}')"
    rows.append(row)

sql = "INSERT INTO customer (first_name, middle_name, last_name, email, phone_number, date_of_birth, gender, registration_date, last_login_date, nationality)\nVALUES\n"
sql += ",\n".join(rows) + ";"

print(sql)