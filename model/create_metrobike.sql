CREATE DATABASE IF NOT EXISTS metrobike_dw;
USE metrobike_dw;

-- DIMENSION TABLES

-- DATE DIMENSION
CREATE TABLE dim_date (
    date_sk INT AUTO_INCREMENT PRIMARY KEY,
    full_date DATE,
    year INT,
    quarter INT,
    month INT,
    day INT,
    weekday VARCHAR(15)
);

-- KIOSK DIMENSION
CREATE TABLE dim_kiosk (
    kiosk_sk INT AUTO_INCREMENT PRIMARY KEY,
    kiosk_id VARCHAR(50),
    kiosk_name VARCHAR(255),
    kiosk_location VARCHAR(255)
);

-- BIKE DIMENSION
CREATE TABLE dim_bike (
    bike_sk INT AUTO_INCREMENT PRIMARY KEY,
    bicycle_id VARCHAR(50),
    bike_type VARCHAR(100)
);

-- MEMBERSHIP DIMENSION
CREATE TABLE dim_membership (
    membership_sk INT AUTO_INCREMENT PRIMARY KEY,
    membership_type VARCHAR(100)
);


-- FACT TABLE

CREATE TABLE fact_bike_trips (
    trip_sk INT AUTO_INCREMENT PRIMARY KEY,
    trip_id BIGINT,
    date_sk INT,
    checkout_kiosk_sk INT,
    return_kiosk_sk INT,
    bike_sk INT,
    membership_sk INT,
    duration_minutes INT,
    FOREIGN KEY (date_sk) REFERENCES dim_date(date_sk),
    FOREIGN KEY (checkout_kiosk_sk) REFERENCES dim_kiosk(kiosk_sk),
    FOREIGN KEY (return_kiosk_sk) REFERENCES dim_kiosk(kiosk_sk),
    FOREIGN KEY (bike_sk) REFERENCES dim_bike(bike_sk),
    FOREIGN KEY (membership_sk) REFERENCES dim_membership(membership_sk)
);
