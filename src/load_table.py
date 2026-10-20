import os
import pandas as pd
from sqlalchemy import create_engine, text, URL
from dotenv import load_dotenv

load_dotenv()

df = pd.read_csv(
    "../Data/Processed/BankChurners_Clean.csv",
    dtype={"customer_id": "string"}
)

password = os.getenv("POSTGRES_PASSWORD")

url = URL.create(
    drivername="postgresql+psycopg2",
    username="postgres",
    password=password,
    host="localhost",
    port=5432,
    database="bank_data"
)

engine = create_engine(url)

with engine.connect() as connection:
    version = connection.execute(text("SELECT version();")).scalar()
    print(version)

print("Database connected successfully.")

df.to_sql(
    name="bank_data",
    con=engine,
    if_exists="append",
    index=False,
)

print(f"Loaded {len(df)} rows into bank_data.")