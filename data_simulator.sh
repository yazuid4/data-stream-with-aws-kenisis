#!/bin/bash
# The commands generate click stream events with the following characteristics:
#	- 5000 thousand events created
#	- Events have 2 seconds interval between them
#	- After every 60 events there is a 15 seconds interval

echo '{
  "user_id": "$USER_ID",
  "event_timestamp": "$EVENT_TIMESTAMP",
  "event_name": "$EVENT_NAME",
  "event_type": "click",
  "device_type": "desktop"
}' > event_template.json

DATA_STREAM="click-stream"
USER_IDS=(user1 user2 user3 user4)
EVENTS=(search navigate detail checkout)
for i in $(seq 1 5000); do
    echo "Iteration: ${i}"
    export USER_ID="${USER_IDS[RANDOM%${#USER_IDS[@]}]}";
    export EVENT_NAME="${EVENTS[RANDOM%${#EVENTS[@]}]}";
    export EVENT_TIMESTAMP=$(($(date +%s) * 1000))
    JSON=$(cat event_template.json | envsubst)
    echo $JSON
    aws kinesis put-record --stream-name $DATA_STREAM --data "${JSON}" --partition-key 1 --region us-west-2
    session_interval=15
    click_interval=2
    if ! (($i%60)); then
        sleep ${session_interval}
    else
        sleep ${click_interval}
    fi
done
