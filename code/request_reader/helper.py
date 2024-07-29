import boto3
import boto3.dynamodb


class Logger:
    def __init__(self, request: dict):
        self.request = request

    def out(self, status: str) -> dict:
        return {
            "request_content": self.request,
            "status": {status}
        }


class RequestTable:
    # https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/API_Query_v20111205.html
    def __init__(self, table_name: str):
        self.client = boto3.client('dynamodb')
        self.paginator = self.client.get_paginator('query')
        self.table_name = table_name

    def get_flagged_requests(self):
        params = {
            'TableName': self.table_name,
            'Hash'
            'KeyConditionExpression': 'pk = :pk_val',
            'ExpressionAttributeValues': {
                ':pk_val': {'S': 'True'},
            }
        }
        pass

    def get_no_flag_requests(self):
        pass
