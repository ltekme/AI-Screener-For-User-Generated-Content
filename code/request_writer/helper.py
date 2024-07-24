import boto3


class Logger:
    def __init__(self, request: dict):
        self.request = request

    def out(self, status: str) -> dict:
        return {
            "request_content": self.request,
            "status": {status}
        }


class RequestTable:
    def __init__(self, table_name: str):
        self.client = boto3.client('dynamodb')
        self.table_name = table_name

    def put_flagged_request(self,
                            title: str,
                            body: str,
                            timestamp: str,
                            requester_ip: str,
                            flagged_reason: str):
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
