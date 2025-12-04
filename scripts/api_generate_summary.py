import pandas as pd
import psycopg2
from fastapi.responses import StreamingResponse
from io import StringIO
from fastapi import FastAPI
from scripts.config import (
    REDSHIFT_HOST,
    REDSHIFT_PORT,
    REDSHIFT_DB,
    REDSHIFT_USER,
    REDSHIFT_PASSWORD
)

app = FastAPI()


# This Script is for Serve Data API requirement:
# Connects to Redshift and generate a dataset summary
# Outputs a CSV file

#run SQL in redshift
def run_query(sql):
    conn = psycopg2.connect(
        host=REDSHIFT_HOST,
        port=REDSHIFT_PORT,
        database=REDSHIFT_DB,
        user=REDSHIFT_USER,
        password=REDSHIFT_PASSWORD
    )
    df = pd.read_sql(sql, conn)
    conn.close()
    return df

#Endpoint
@app.get("/generate-summary")
def generate_summary():
    """
    Generates a CSV summary of MetroBike trips

    """

    sql = """
    SELECT
        d.year,
        d.month,
        m.membership_type,
        COUNT(f.trip_id) AS trip_count
    FROM metrobike.fact_bike_trips f
    JOIN metrobike.dim_date d
        ON f.date_sk = d.date_sk
    JOIN metrobike.dim_membership m
        ON f.membership_sk = m.membership_sk
    GROUP BY d.year, d.month, m.membership_type
    ORDER BY d.year, d.month, m.membership_type;
"""


    df = run_query(sql)

    buffer = StringIO()
    df.to_csv(buffer, index=False)
    buffer.seek(0)

    return StreamingResponse(
        buffer,
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=metrobike_summary.csv"}
    )

