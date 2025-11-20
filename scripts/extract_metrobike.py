import requests
import pandas as pd
import time
from scripts.config import APP_TOKEN

url = "https://data.austintexas.gov/api/v3/views/tyfh-5r8s/query.json?query=SELECT%0A%20%20%60trip_id%60%2C%0A%20%20%60membership_type%60%2C%0A%20%20%60bicycle_id%60%2C%0A%20%20%60bike_type%60%2C%0A%20%20%60checkout_datetime%60%2C%0A%20%20%60checkout_date%60%2C%0A%20%20%60checkout_time%60%2C%0A%20%20%60checkout_kiosk_id%60%2C%0A%20%20%60checkout_kiosk%60%2C%0A%20%20%60return_kiosk_id%60%2C%0A%20%20%60return_kiosk%60%2C%0A%20%20%60trip_duration_minutes%60%2C%0A%20%20%60month%60%2C%0A%20%20%60year%60%0AWHERE%0A%20%20%60checkout_date%60%0A%20%20%20%20BETWEEN%20%222024-04-30T00%3A00%3A00%22%20%3A%3A%20floating_timestamp%0A%20%20%20%20AND%20%222024-07-01T18%3A56%3A04%22%20%3A%3A%20floating_timestamp%0AORDER%20BY%20%60checkout_date%60%20DESC%20NULL%20LAST"


#url = "https://data.austintexas.gov/api/v3/views/tyfh-5r8s/query.json"


headers = {"X-App-Token": APP_TOKEN}

print("Requesting filtered MetroBike data...")

response = requests.get(url, headers=headers, timeout=30)
response.raise_for_status()

rows = response.json()

df = pd.DataFrame(rows)

os.makedirs("raw_data", exist_ok=True)
local_path = "raw_data/metrobike_raw.csv"

df.to_csv(local_path, index=False)

print("Saved filtered data:", len(df), "rows")
