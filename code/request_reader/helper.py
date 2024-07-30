import boto3
import boto3.dynamodb


class Logger:
    def __init__(self, request: dict, sender_ip: str):
        self.request = request
        self.sender_ip = sender_ip

    def out(self, status: str) -> dict:
        return {
            "query_string": self.request,
            "sender_ip": self.sender_ip,
            "status": status
        }


class RequestTable:
    def __init__(self, table_name: str):
        self.client = boto3.client('dynamodb', region_name='us-east-1')
        self.table_name = table_name
        self.paginator = self.client.get_paginator('query')

    def flagged(self, last_timestamp: str = None, item_per_page: int = 10):
        return self.make_response('True', last_timestamp, item_per_page)

    def not_flagged(self, last_timestamp: str = None, item_per_page: int = 10):
        return self.make_response('False', last_timestamp, item_per_page)

    def make_response(self, flag: str, last_timespamp: str = None, item_per_page: int = 10):

        class Response:
            def __init__(self, paginator, table_name: str, flag: str, last_eval_key: dict = {}, item_per_page: int = 10):
                params = {
                    'TableName': table_name,
                    'KeyConditionExpression': 'flagged = :pk_val',
                    'ExpressionAttributeValues': {':pk_val': {'S': flag}},
                    'PaginationConfig': {'MaxItems': item_per_page, 'PageSize': item_per_page}
                }
                if last_eval_key != {}:
                    params['ExclusiveStartKey'] = last_eval_key
                self.pages = [page for page in paginator.paginate(**params)]

            def construct_client_response_item(self, dynamo_item: dict) -> dict:
                item = {}
                item['title'] = dynamo_item.get('title').get('S')
                item['body'] = dynamo_item.get('body').get('S')
                item['timestamp'] = dynamo_item.get('timestamp').get('S')

                if dynamo_item.get('flagged').get('S') == 'True':
                    item['requester_ip'] = dynamo_item.get(
                        'requester_ip').get('S')
                    item['flagged_reason'] = dynamo_item.get(
                        'flagged_reason').get('S')

                return item

            @property
            def last_timestamp(self):
                if self.pages[0].get('LastEvaluatedKey') is None:
                    return None
                return self.pages[0].get('LastEvaluatedKey').get('timestamp').get('S')

            @property
            def items(self):
                all_items = []
                for page in self.pages:
                    all_items.extend(page.get('Items'))

                return [self.construct_client_response_item(item) for item in all_items]

        if last_timespamp:
            last_eval_key = {'flagged': {'S': flag},
                             'timestamp': {'S': last_timespamp}}
            return Response(self.paginator, self.table_name, flag, last_eval_key, item_per_page)

        return Response(self.paginator, self.table_name, flag=flag, item_per_page=item_per_page)
