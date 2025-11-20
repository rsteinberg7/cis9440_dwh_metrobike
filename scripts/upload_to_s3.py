# this is to upload to s3 only without re-extracting data
import boto3

bucket_name = "cis9440-assignment-metrobike"
file_path = "raw_data/metrobike_raw.csv"
s3_key = "raw/metrobike_raw.csv"

s3 = boto3.client("s3")

print("Uploading file to S3...")
s3.upload_file(file_path, bucket_name, s3_key)

print(f"Uploaded to s3://{bucket_name}/{s3_key}")