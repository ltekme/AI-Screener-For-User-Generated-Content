import boto3
import datetime

TABLE_NAME = 'AI_Content_Screener-UserRequest'


class RequestTable:
    def __init__(self, table_name: str):
        self.client = boto3.client('dynamodb', region_name='us-east-1')
        self.table_name = table_name

    def put_unflagged_request(self, title: str, body: str, timestamp: str):
        self.client.put_item(
            TableName=self.table_name,
            Item={
                'flagged': {'S': "False"},
                'timestamp': {'S': timestamp},
                'title': {'S': title},
                'body': {'S': body},
            }
        )

    def put_flagged_request(self, title: str, body: str, timestamp: str, requester_ip: str, flagged_reason: str):
        self.client.put_item(
            TableName=self.table_name,
            Item={
                'flagged': {'S': "True"},
                'timestamp': {'S': timestamp},
                'title': {'S': title},
                'body': {'S': body},
                'requester_ip': {'S': requester_ip},
                'flagged_reason': {'S': flagged_reason}
            }
        )


def generate_good_request(count=1):
    request_table = RequestTable(TABLE_NAME)
    for i in range(count):
        print(f'good request title {i}')
        request_table.put_unflagged_request(
            title=f'good request title {i}',
            body=f'good request body {i}',
            timestamp=datetime.datetime.utcnow().isoformat()  # [:-6]
        )


def generate_bad_request(count=1):
    request_table = RequestTable(TABLE_NAME)
    for i in range(count):
        print(f'bad request title {i}')
        request_table.put_flagged_request(
            title=f'bad request title {i}',
            body=f'bad request body {i}',
            timestamp=datetime.datetime.utcnow().isoformat(),  # [:-6]
            requester_ip=f'bad ip {i}',
            flagged_reason=f'bad reason {i}'
        )


if __name__ == '__main__':
    generate_good_request(40)
    generate_bad_request(40)
