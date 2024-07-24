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
import boto3


class Logger:
    def __init__(self, request: dict):
        self.request = request

    def out(self, status: str):
        return {
            "request_content": self.request,
            "status": status
        }


def validate_request(request_content: dict) -> None:
    """Validate User Request"""
    if 'title' not in request_content:
        raise Exception("Title is required")
    if 'body' not in request_content:
        raise Exception("Body is required")
    if len(request_content['body']) > 500:
        raise Exception("Body must be less than 500 characters long")
    if len(request_content['title']) > 64:
        raise Exception("Title must be less than 500 characters long")


def send_to_sqs(sqs_queue_url: str, request_content: dict) -> None:
    """Send User Request to SQS"""
    client = boto3.client('sqs')
    client.send_message(
        QueueUrl=sqs_queue_url,
        MessageBody=json.dumps(request_content)
    )


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

    # Validate Request
    try:
        validate_request(request_content)
    except Exception as e:
        print(logger.out(e))
        response["statusCode"] = 400
        response["body"] = json.dumps({"Error": str(e)})
        return response

    # Add Timestamp and Requester IP
    request_content['timestamp'] = str(event['requestContext']['requestTime'])
    request_content['requester_ip'] = event['requestContext']['identity']['sourceIp']

    # Send to SQS
    try:
        send_to_sqs(SQS_QUEUE_URL, request_content)
    except Exception as e:
        print(logger.out(e))
        response["statusCode"] = 500
        response["body"] = json.dumps({"Error": "Internal Server Error"})
        return response

    print(logger.out("Success"))

    return response
