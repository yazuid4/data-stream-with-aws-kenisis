%flink.ssql(type=update)
DROP TABLE IF EXISTS session_stream;
CREATE TABLE session_stream (
          user_id STRING,
          session_timestamp BIGINT,
          session_time TIMESTAMP(3),
          session_id STRING,
          event_type STRING,
          device_type STRING
) PARTITIONED BY (user_id) WITH (
  'connector' = 'kinesis',
  'stream' = 'session-stream',
  'aws.region' = 'us-west-2',
  'format' = 'json'
);

INSERT INTO session_stream
SELECT
  user_id,
  session_timestamp,
  session_time,
  session_id,
  event_type,
  device_type
FROM (
    SELECT 
      *, 
      user_id || '_' || CAST(
        SUM(new_session) OVER (
          PARTITION BY user_id 
          ORDER BY 
            event_time
        ) AS STRING
      ) AS session_id, 
      event_time as session_time, 
      event_timestamp as session_timestamp 
    FROM 
      (
        SELECT 
          *, 
          CASE WHEN event_timestamp - LAG(event_timestamp) OVER (
            PARTITION BY user_id 
            ORDER BY 
              event_time
          ) >= (10 * 1000) THEN 1 ELSE 0 END as new_session 
        FROM 
          click_stream
      ) 
    WHERE 
      new_session = 1
);