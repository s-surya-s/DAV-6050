-- DROP SCHEMA citibike_dw cascade;
CREATE SCHEMA IF NOT EXISTS citibike_dw;

CREATE  TABLE  IF NOT EXISTS citibike_dw.date_dim ( 
	date_sk_id           SERIAL PRIMARY KEY,
	"date"            	 DATE   NOT NULL   ,
	year                 INT    NOT NULL   ,
	quarter              INT    NOT NULL   ,
	month                INT    NOT NULL   ,
	day                  INT    NOT NULL   
 );

CREATE  TABLE  IF NOT EXISTS citibike_dw.member_type_dim ( 
	member_type_sk_id   SERIAL PRIMARY KEY,
	member_type_desc    TEXT   NOT NULL   
 );

CREATE  TABLE  IF NOT EXISTS citibike_dw.rideable_type_dim ( 
	rideable_type_sk_id  SERIAL PRIMARY KEY,
	rideable_type_desc   TEXT   NOT NULL   
 );

CREATE  TABLE  IF NOT EXISTS citibike_dw.station_dim ( 
	station_sk_id        SERIAL PRIMARY KEY,
	station_id           TEXT    		NOT NULL,
	station_name         VARCHAR(100)  NOT NULL,
	station_lat	     NUMERIC,
	station_lng	     NUMERIC
 );

CREATE  TABLE  IF NOT EXISTS citibike_dw.weather_dim ( 
	weather_sk_id        SERIAL PRIMARY KEY,
	weather_name         VARCHAR(100)    NOT NULL   
 );

CREATE  TABLE  IF NOT EXISTS citibike_dw.rides_fact ( 
	date_sk_id           INT    NOT NULL,
	start_station_sk_id  INT    NOT NULL,
	end_station_sk_id    INT    NOT NULL,
	member_type_sk_id    INT    NOT NULL,
	rideable_type_sk_id  INT    NOT NULL,
	weather_sk_id        INT    NOT NULL,
	total_usage_seconds  INT    NOT NULL,
	total_rides_count    INT    NOT NULL,
	total_fare           INT    NOT NULL,
	CONSTRAINT pk_ride_fact PRIMARY KEY ( date_sk_id, start_station_sk_id, end_station_sk_id, member_type_sk_id, rideable_type_sk_id, weather_sk_id ),
	FOREIGN KEY (date_sk_id) 			REFERENCES citibike_dw.date_dim(date_sk_id),
	FOREIGN KEY (start_station_sk_id)	REFERENCES citibike_dw.station_dim(station_sk_id),
	FOREIGN KEY (end_station_sk_id)		REFERENCES citibike_dw.station_dim(station_sk_id),
	FOREIGN KEY (member_type_sk_id) 	REFERENCES citibike_dw.member_type_dim(member_type_sk_id),
	FOREIGN KEY (rideable_type_sk_id) 	REFERENCES citibike_dw.rideable_type_dim(rideable_type_sk_id),
	FOREIGN KEY (weather_sk_id) 		REFERENCES citibike_dw.weather_dim(weather_sk_id)
);