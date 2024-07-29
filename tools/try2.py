import boto3
import datetime


class RequestTable:
    def __init__(self, table_name: str):
        self.client = boto3.client('dynamodb', region_name='us-east-1')
        self.table_name = table_name

    def put_unflagged_request(self,
                              title: str,
                              body: str,
                              timestamp: str):
        self.client.put_item(
            TableName=self.table_name,
            Item={
                'flagged': {'S': "False"},
                'timestamp': {'S': timestamp},
                'title': {'S': title},
                'body': {'S': body},
            }
        )


request_table = RequestTable('AI_Content_Screener-UserRequest')
for i in range(300):
    request_table.put_unflagged_request(
        title=f'title{i}',
        body=f'body{i}',
        timestamp=datetime.datetime.utcnow().isoformat()#[:-6]
    )
