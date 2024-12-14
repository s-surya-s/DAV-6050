-- Insert data into the date_dim table
INSERT INTO citibike_dw.date_dim (date, year, quarter, month, day)
SELECT 
DATE(started_at), 
EXTRACT(YEAR FROM started_at),
EXTRACT(QUARTER FROM started_at),
EXTRACT(MONTH FROM started_at),
EXTRACT(DAY FROM started_at)
FROM public.cleaned_citibike_trips
GROUP BY 1,2,3,4,5
ORDER BY 1;

-- Insert data into the member_type_dim table
INSERT INTO citibike_dw.member_type_dim (member_type_desc)
SELECT DISTINCT member_casual
FROM public.cleaned_citibike_trips;

-- Insert data into the rideable_type_dim table
INSERT INTO citibike_dw.rideable_type_dim (rideable_type_desc)
SELECT DISTINCT rideable_type
FROM public.cleaned_citibike_trips;

-- Insert data into the station_dim table
INSERT INTO citibike_dw.station_dim (station_id, station_name, station_lat, station_lng)
SELECT start_station_id, start_station_name, start_lat, start_lng
FROM 
(
	SELECT start_station_id, start_station_name, start_lat, start_lng,
	ROW_NUMBER() OVER (PARTITION BY start_station_name) AS rnk
	FROM		
	(
		SELECT start_station_id, start_station_name, start_lat, start_lng
		FROM public.cleaned_citibike_trips
		GROUP BY 1,2,3,4
		UNION 
		SELECT end_station_id, end_station_name, end_lat, end_lng
		FROM public.cleaned_citibike_trips
		GROUP BY 1,2,3,4
	)stn
)sss
WHERE rnk = 1;

-- Insert data into the weather_dim table
INSERT INTO citibike_dw.weather_dim (weather_name)
SELECT DISTINCT icon
FROM public.weather;

-- Insert data into the fact table
WITH base as(
SELECT * FROM public.cleaned_citibike_trips c
JOIN public.weather w
ON DATE(c.started_at) = w.date)
INSERT INTO citibike_dw.rides_fact (
	date_sk_id, 
	start_station_sk_id,
	end_station_sk_id,
	member_type_sk_id, 
	rideable_type_sk_id, 
	weather_sk_id, 
	total_usage_seconds, 
	total_rides_count, 
	total_fare)
SELECT 
dat.date_sk_id,
st_stn.station_sk_id,
en_stn.station_sk_id,
mem.member_type_sk_id,
rid.rideable_type_sk_id,
wth.weather_sk_id, 
sum(trip_duration), 
count(*), 
SUM(
	CASE 
		WHEN A.member_casual = 'casual' THEN 
			-- Casual member charges
			CASE 
				WHEN A.rideable_type = 'ebike' THEN (trip_duration / 60) * 0.36 + 4.79  -- EBike rate for casual + unlock fee
				ELSE 4.79  -- Standard bike for casual + unlock fee
			END
		WHEN A.member_casual = 'member' THEN 
			-- Member charges
			CASE 
				WHEN A.rideable_type = 'ebike' THEN (trip_duration / 60) * 0.24  -- EBike rate for member
				ELSE 0  -- Standard bike for member (no unlock fee)
			END
		ELSE 0
	END
) AS total_fare
FROM base A
JOIN citibike_dw.date_dim dat ON date(A.started_at) = dat.date
JOIN citibike_dw.member_type_dim mem ON A.member_casual =  mem.member_type_desc
JOIN citibike_dw.rideable_type_dim rid ON A.rideable_type = rid.rideable_type_desc
JOIN citibike_dw.station_dim st_stn ON A.start_station_name = st_stn.station_name
JOIN citibike_dw.station_dim en_stn ON A.end_station_name = en_stn.station_name
JOIN citibike_dw.weather_dim wth ON A.icon = wth.weather_name
GROUP BY 1,2,3,4,5,6;
