-- CREATE SCHEMA
CREATE SCHEMA IF NOT EXISTS metrobike;

-- CREATE STAGING TABLE
CREATE TABLE IF NOT EXISTS metrobike.staging_trips (
    trip_id BIGINT,
    membership_type VARCHAR(100),
    bicycle_id VARCHAR(50),
    bike_type VARCHAR(50),
    checkout_datetime VARCHAR(50),
    checkout_date DATE,
    checkout_time VARCHAR(50),
    checkout_kiosk_id VARCHAR(50),
    checkout_kiosk VARCHAR(255),
    return_kiosk_id VARCHAR(50),
    return_kiosk VARCHAR(255),
    trip_duration_minutes INT,
    month INT,
    year INT,
    socrata_id VARCHAR(50),
    socrata_version VARCHAR(50),
    socrata_created_at VARCHAR(50),
    socrata_updated_at VARCHAR(50)
);

-- DATE DIMENSION
CREATE TABLE IF NOT EXISTS metrobike.dim_date (
    date_sk INTEGER IDENTITY(1,1) PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year INT,
    quarter INT,
    month INT,
    day INT,
    weekday VARCHAR(15)
);

-- KIOSK DIMENSION
CREATE TABLE IF NOT EXISTS metrobike.dim_kiosk (
    kiosk_sk INTEGER IDENTITY(1,1) PRIMARY KEY,
    kiosk_id VARCHAR(50),
    kiosk_name VARCHAR(255),
    kiosk_location VARCHAR(255)
);

-- BIKE DIMENSION
CREATE TABLE IF NOT EXISTS metrobike.dim_bike (
    bike_sk INTEGER IDENTITY(1,1) PRIMARY KEY,
    bicycle_id VARCHAR(50),
    bike_type VARCHAR(100)
);

-- MEMBERSHIP DIMENSION
CREATE TABLE IF NOT EXISTS metrobike.dim_membership (
    membership_sk INTEGER IDENTITY(1,1) PRIMARY KEY,
    membership_type VARCHAR(100)
);

-- FACT TABLE
CREATE TABLE IF NOT EXISTS metrobike.fact_bike_trips (
    trip_sk INTEGER IDENTITY(1,1) PRIMARY KEY,
    trip_id BIGINT,
    date_sk INT REFERENCES metrobike.dim_date(date_sk),
    checkout_kiosk_sk INT REFERENCES metrobike.dim_kiosk(kiosk_sk),
    return_kiosk_sk INT REFERENCES metrobike.dim_kiosk(kiosk_sk),
    bike_sk INT REFERENCES metrobike.dim_bike(bike_sk),
    membership_sk INT REFERENCES metrobike.dim_membership(membership_sk),
    duration_minutes INT
);
