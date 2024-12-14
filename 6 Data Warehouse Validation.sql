SELECT  date, station_name,
ROUND(SUM(total_usage_hours),2) as usage_hours,
SUM(total_rides_count) as rides_count,
ROUND(SUM(total_fare),2) as total_fare
FROM citibike_dw.rides_fact A
JOIN citibike_dw.date_dim dat ON A.date_sk_id = dat.date_sk_id
JOIN citibike_dw.member_type_dim mem ON A.member_type_sk_id =  mem.member_type_sk_id
JOIN citibike_dw.rideable_type_dim rid ON A.rideable_type_sk_id = rid.rideable_type_sk_id
JOIN citibike_dw.station_dim stn ON A.station_sk_id = stn.station_sk_id
JOIN citibike_dw.weather_dim wth ON A.weather_sk_id = wth.weather_sk_id
GROUP BY 1,2
LIMIT 10