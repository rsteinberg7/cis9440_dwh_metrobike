# cis9440_dwh_metrobike
Rina Steinberg
CIS 9440
Austin MetroBike Trips-Data Warehouse Project

## Data Sources
Primary dataset:
https://data.austintexas.gov/Transportation-and-Mobility/Austin-MetroBike-Trips/tyfh-5r8s

API endpoint:
https://data.austintexas.gov/api/v3/views/tyfh-5r8s/query.json

## Data Dictionary:
`/data_dictionary/metrobike_data_dictionary.xlsx`

## Note about data
/raw_data directory holds manually downloaded metrobike csv and xlsx files for comparison to the one generated from extract_and_store.py to confirm data was extracted correctly

## Storage Choice
I selected AWS S3 as my data storage. S3 is reliable, scalable, and supports integration with Redshift, which will be required for Assignment 2.

## Storage Setup

Storage used: AWS S3  
Bucket name :`cis9440-assignment-metrobike`

Folder structure:
s3://`cis9440-assignment-metrobike`/raw/metrobike_raw.csv

To run the script with S3 upload:
1. Create config.py in folder using config_template.py
2. Install boto3
3. Run: python extract_and_store.py


## Data Warehouse Model

The warehouse uses a star schema with one fact table and four dimension tables.

Fact table:
- fact_bike_trips

Dimension tables:
- dim_date
- dim_kiosk
- dim_bike
- dim_membership

The SQL script to create the warehouse is located in:
model/create_warehouse.sql


## Script Used:
`scripts/extract_and_store.py`

This script:

* Pulls MetroBike trip data from the API
* Saves it to `raw_data/metrobike_raw.csv`
* Uploads the file to the S3 bucket


## Warehouse Creation Script:**
`models/create_metrobike.sql`

## ETL Script:
`scripts/load_dw.py`
Loads the dimension tables and fact table