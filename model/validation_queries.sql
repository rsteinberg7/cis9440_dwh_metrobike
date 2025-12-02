--Some test queries to confirm successful loading and copying of data

-- VALIDATION
SELECT COUNT(*) AS staging_rows FROM metrobike.staging_trips;

SELECT
    (SELECT COUNT(*) FROM metrobike.dim_date) AS dim_date_count,
    (SELECT COUNT(*) FROM metrobike.dim_bike) AS dim_bike_count,
    (SELECT COUNT(*) FROM metrobike.dim_membership) AS dim_membership_count,
    (SELECT COUNT(*) FROM metrobike.dim_kiosk) AS dim_kiosk_count;

SELECT COUNT(*) AS fact_row_count
FROM metrobike.fact_bike_trips;

SELECT *
FROM metrobike.fact_bike_trips f
JOIN metrobike.dim_date d ON f.date_sk = d.date_sk
JOIN metrobike.dim_bike b ON f.bike_sk = b.bike_sk
JOIN metrobike.dim_kiosk ck ON f.checkout_kiosk_sk = ck.kiosk_sk
JOIN metrobike.dim_kiosk rk ON f.return_kiosk_sk = rk.kiosk_sk
JOIN metrobike.dim_membership m ON f.membership_sk = m.membership_sk
LIMIT 30;
