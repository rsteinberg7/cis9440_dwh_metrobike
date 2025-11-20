import pandas as pd
from datetime import datetime
import pymysql
from config import MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE


# Load extracted data
df = pd.read_csv("raw_data/metrobike_raw.csv")

# Connect to MySQL DW
conn = pymysql.connect(
    host=MYSQL_HOST,
    user=MYSQL_USER,
    password=MYSQL_PASSWORD,
    database=MYSQL_DATABASE,
    charset="utf8mb4",
    cursorclass=pymysql.cursors.Cursor
)

cursor = conn.cursor()

# LOAD dim_date
date_values = df["checkout_date"].dropna().drop_duplicates()

for date_str in date_values:
    full_date = pd.to_datetime(date_str).date()
    year = full_date.year
    quarter = (full_date.month - 1) // 3 + 1
    month = full_date.month
    day = full_date.day
    weekday = full_date.strftime("%A")

    cursor.execute("""
        INSERT INTO dim_date (full_date, year, quarter, month, day, weekday)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (full_date, year, quarter, month, day, weekday))


# LOAD dim_bike
bike_df = df[['bicycle_id', 'bike_type']].dropna().drop_duplicates()

for _, row in bike_df.iterrows():
    cursor.execute("""
        INSERT INTO dim_bike (bicycle_id, bike_type)
        VALUES (%s, %s)
    """, (row['bicycle_id'], row['bike_type']))


# LOAD dim_membership
membership_df = df[['membership_type']].dropna().drop_duplicates()

for _, row in membership_df.iterrows():
    cursor.execute("""
        INSERT INTO dim_membership (membership_type)
        VALUES (%s)
    """, (row['membership_type'],))


# LOAD dim_kiosk
kiosk_df = df[['checkout_kiosk_id', 'checkout_kiosk']].drop_duplicates()

for _, row in kiosk_df.iterrows():
    cursor.execute("""
        INSERT INTO dim_kiosk (kiosk_id, kiosk_name, kiosk_location)
        VALUES (%s, %s, %s)
    """, (row['checkout_kiosk_id'], row['checkout_kiosk'], row['checkout_kiosk']))


# LOAD fact_bike_trips
for _, row in df.iterrows():

    # date_sk
    cursor.execute("SELECT date_sk FROM dim_date WHERE full_date = %s", (row['checkout_date'],))
    date_sk = cursor.fetchone()[0]

    # bike_sk
    cursor.execute("SELECT bike_sk FROM dim_bike WHERE bicycle_id = %s", (row['bicycle_id'],))
    bike_sk = cursor.fetchone()[0]

    # membership_sk
    cursor.execute("SELECT membership_sk FROM dim_membership WHERE membership_type = %s", (row['membership_type'],))
    membership_sk = cursor.fetchone()[0]

    # checkout kiosk
    cursor.execute("SELECT kiosk_sk FROM dim_kiosk WHERE kiosk_id = %s", (row['checkout_kiosk_id'],))
    checkout_kiosk_sk = cursor.fetchone()[0]

    # return kiosk
    cursor.execute("SELECT kiosk_sk FROM dim_kiosk WHERE kiosk_id = %s", (row['return_kiosk_id'],))
    return_kiosk_sk = cursor.fetchone()[0]

    # insert fact row
    cursor.execute("""
        INSERT INTO fact_bike_trips (
            trip_id,
            date_sk,
            checkout_kiosk_sk,
            return_kiosk_sk,
            bike_sk,
            membership_sk,
            duration_minutes
        ) VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (
        row['trip_id'],
        date_sk,
        checkout_kiosk_sk,
        return_kiosk_sk,
        bike_sk,
        membership_sk,
        row['trip_duration_minutes'],
    ))

conn.commit()
cursor.close()
conn.close()

print("Data warehouse load completed.")
