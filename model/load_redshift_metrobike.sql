-- LOAD RAW DATA FROM S3 INTO STAGING TABLE
COPY metrobike.staging_trips
FROM 's3://<INSERTBUCKETNAMEHERE>/raw/metrobike_raw.csv'
IAM_ROLE 'INSERT IAM ROLE HERE'
FORMAT AS CSV
IGNOREHEADER 1;

-- POPULATE DIMENSION: DATE
INSERT INTO metrobike.dim_date (full_date, year, quarter, month, day, weekday)
SELECT DISTINCT
    checkout_date,
    EXTRACT(year FROM checkout_date),
    EXTRACT(quarter FROM checkout_date),
    EXTRACT(month FROM checkout_date),
    EXTRACT(day FROM checkout_date),
    TRIM(TO_CHAR(checkout_date, 'Day'))
FROM metrobike.staging_trips
WHERE checkout_date IS NOT NULL;

-- POPULATE DIMENSION: BIKE
INSERT INTO metrobike.dim_bike (bicycle_id, bike_type)
SELECT DISTINCT bicycle_id, bike_type
FROM metrobike.staging_trips
WHERE bicycle_id IS NOT NULL;

-- POPULATE DIMENSION: MEMBERSHIP
INSERT INTO metrobike.dim_membership (membership_type)
SELECT DISTINCT membership_type
FROM metrobike.staging_trips
WHERE membership_type IS NOT NULL;

-- POPULATE DIMENSION: KIOSK (checkout kiosks)
INSERT INTO metrobike.dim_kiosk (kiosk_id, kiosk_name, kiosk_location)
SELECT DISTINCT checkout_kiosk_id, checkout_kiosk, checkout_kiosk
FROM metrobike.staging_trips
WHERE checkout_kiosk_id IS NOT NULL;

-- POPULATE DIMENSION: KIOSK (missing return kiosks)
INSERT INTO metrobike.dim_kiosk (kiosk_id, kiosk_name, kiosk_location)
SELECT DISTINCT return_kiosk_id, return_kiosk, return_kiosk
FROM metrobike.staging_trips
WHERE return_kiosk_id IS NOT NULL
AND return_kiosk_id NOT IN (SELECT kiosk_id FROM metrobike.dim_kiosk);

-- POPULATE FACT TABLE
INSERT INTO metrobike.fact_bike_trips (
    trip_id, date_sk, checkout_kiosk_sk, return_kiosk_sk, bike_sk, membership_sk, duration_minutes
)
SELECT
    s.trip_id,
    d.date_sk,
    ck.kiosk_sk,
    rk.kiosk_sk,
    b.bike_sk,
    m.membership_sk,
    s.trip_duration_minutes
FROM metrobike.staging_trips s
JOIN metrobike.dim_date d ON s.checkout_date = d.full_date
JOIN metrobike.dim_bike b ON s.bicycle_id = b.bicycle_id
JOIN metrobike.dim_membership m ON s.membership_type = m.membership_type
JOIN metrobike.dim_kiosk ck ON s.checkout_kiosk_id = ck.kiosk_id
JOIN metrobike.dim_kiosk rk ON s.return_kiosk_id = rk.kiosk_id;
