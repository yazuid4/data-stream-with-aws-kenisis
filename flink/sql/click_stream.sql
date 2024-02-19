%flink.ssql(type = update)
DROP TABLE IF EXISTS click_stream;
CREATE TABLE click_stream (
          user_id STRING,
          event_timestamp BIGINT,
          event_name STRING,
          event_type STRING,
          device_type STRING,
          event_time AS TO_TIMESTAMP(FROM_UNIXTIME(event_timestamp/1000)),
	        WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (
  'connector' = 'kinesis',
  'stream' = 'click-stream',
  'aws.region' = 'us-west-2',
  'scan.startup.mode' = 'latest-offset',
  'format' = 'json'
);
