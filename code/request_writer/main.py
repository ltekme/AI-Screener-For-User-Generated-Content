"""Lambda Function to Write Request To DynamoDB

Expected Input Body:
{
    "title": "Request Title",
    "body": "Request Body"
    "timestamp: "Time of the request"
    "requester_ip": "Requester IP"
}
or
{
    "title": "Request Title",
    "body": "Request Body",
    "timestamp: "Time of the request",
    "requester_ip": "Requester IP",
    "flagged_reason": "Reason for the flag"
}

Environment Variables:
- REQUEST_TABLE_NAME: ARN of request table in DynamoDB

Logger: input user request content
- out: Returns a dictionary with the request_content and status
        {
            "request_content": {},
            "status": Put Item Resault
        }

Handler:
Check for the key 'flagged' in the input request content.
If it exists, mark as flagged.
Put the request in the table.
If the key 'flagged' does not exist, mark as unflagged.
"""

import os
import json

from helper import Logger, RequestTable


def lambda_handler(event, context):
    """Put request in dynamodb"""

    REQUEST_TABLE_NAME: str = os.environ.get('REQUEST_TABLE_NAME')

    response: dict = {
        "statusCode": 200,
        "body": json.dumps({"Message": "Sucess"})
    }

    request_content: dict = json.loads(event['Records'][0]['body'])

    logger: Logger = Logger(request_content)

    request_table = RequestTable(REQUEST_TABLE_NAME)

    if request_content.get('flagged', False):
        request_table.put_flagged_request(
            title=request_content['title'],
            body=request_content['body'],
            timestamp=request_content['timestamp'],
            requester_ip=request_content['requester_ip'],
            flagged_reason=request_content['flagged_reason']
        )

    request_table.put_unflagged_request(
        title=request_content['title'],
        body=request_content['body'],
        timestamp=request_content['timestamp']
    )
    print(logger.out("Record Saved"))

    return response
