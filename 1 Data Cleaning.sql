-- Create a new table `cleaned_citibike_trips` to store cleaned data
-- Select all columns from `citibike_trips` where station names and IDs are non-NULL and not empty strings
CREATE TABLE cleaned_citibike_trips AS
SELECT *
FROM citibike_trips
WHERE start_station_name IS NOT NULL AND start_station_name <> '' -- Exclude rows with NULL or empty start station names
  AND end_station_name IS NOT NULL AND end_station_name <> ''     -- Exclude rows with NULL or empty end station names
  AND start_station_id IS NOT NULL AND start_station_id <> ''     -- Exclude rows with NULL or empty start station IDs
  AND end_station_id IS NOT NULL AND end_station_id <> '';        -- Exclude rows with NULL or empty end station IDs

-- Remove invalid or incomplete records from `cleaned_citibike_trips`
-- Exclude rows where `started_at` is greater than `ended_at`, or where either timestamp is NULL
DELETE FROM cleaned_citibike_trips
WHERE started_at > ended_at                                      -- Exclude rows with illogical timestamps
   OR started_at IS NULL                                         -- Exclude rows with NULL `started_at`
   OR ended_at IS NULL;                                          -- Exclude rows with NULL `ended_at`

-- Add a new column `trip_duration` to store the trip duration in seconds
ALTER TABLE cleaned_citibike_trips
ADD COLUMN trip_duration NUMERIC;

-- Calculate trip duration as the difference between `ended_at` and `started_at` in seconds
-- Only update rows where the duration is logical (greater than 0 seconds and less than 24 hours)
UPDATE cleaned_citibike_trips
SET trip_duration = EXTRACT(EPOCH FROM (ended_at - started_at))  -- Convert interval to seconds
WHERE (ended_at - started_at) > INTERVAL '0 seconds'            -- Ensure duration is positive
  AND (ended_at - started_at) < INTERVAL '24 hours';            -- Exclude trips longer than 24 hours

-- Delete rows with NULL values in trip_duration after the update
DELETE FROM cleaned_citibike_trips
WHERE trip_duration IS NULL;