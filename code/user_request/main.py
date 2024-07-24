"""Lambda Function to Vlidate Requset and Send to SQS

Expected Input Body:
{
    "title": "Hello, World!",
    "body": "This is a test post."
}

Message Sent to SQS:
{
    "title": "Request Title",
    "body": "Request Body"
    "timestamp: "Time of the request"
    "requester_ip": "Requester IP"
}

Environment Variables:
- SQS_QUEUE_URL: URL of the SQS Queue to send the request to be processed

Logger: input user request content
- out: Returns a dictionary with the request_content and status
        {
            "request_content": {
                "title": "Request Title",
                "body": "Request Body"
            },
            "status": Request Validation Resault
        }
"""

import json
import os

from helper import Logger, send_to_sqs, validate_request, ValidationError


def lambda_handler(event, context):
    """Validate User Request and Send to SQS"""

    SQS_QUEUE_URL: str = os.environ.get('SQS_QUEUE_URL')

    response: dict = {
        "statusCode": 200,
        "headers": {
            "content-type": "application/json"
        },
        "body": json.dumps({"Message": "Success"})
    }

    # Get User Request
    request_content: dict = json.loads(event['body'])
    logger: Logger = Logger(request_content)

    try:
        validate_request(request_content)
        request_content['timestamp'] = str(
            event['requestContext']['requestTime'])
        request_content['requester_ip'] = event['requestContext']['identity']['sourceIp']
        send_to_sqs(SQS_QUEUE_URL, request_content)
        print(logger.out("Success"))
        return response

    except ValidationError as e:
        print(logger.out(e))
        response["statusCode"] = 400
        response["body"] = json.dumps({"Error": str(e)})
        return response
