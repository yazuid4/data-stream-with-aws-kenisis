from __future__ import print_function
import boto3
import base64
from json import loads
dynamodb_client = boto3.client('dynamodb')
table_name = "Records"
def lambda_handler(event, context):
    records = event['Records']
    output = []
    success = 0
    failure = 0
    for record in records:
        try:
            payload = base64.b64decode(record['kinesis']['data'])
            data_item = loads(payload)
            ddb_item = {
                'session_id': {'S': data_item['session_id']},
                'session_time': {'S': data_item['session_time']},
                'user_id': {'S': data_item['user_id']}
            }
            dynamodb_client.put_item(TableName=table_name, Item=ddb_item)
            success += 1
            output.append({'recordId': record['eventID'], 'result': 'Ok'})
        except Exception:
            failure += 1
            output.append({'recordId': record['eventID'], 'result': 'DeliveryFailed'})
    print('Successfully delivered {0} records, failed to deliver {1} records'.format(success, failure))
    return {'records': output}