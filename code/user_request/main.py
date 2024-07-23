"""Lambda Function to Vlidate Requset and Send to SQS"""

import json
import os
import boto3


class Logger:
    def __init__(self, request: dict, ip: str):
        self.request = request
        self.ip = ip

    def out(self, status: str):
        print({"requester_ip": self.ip,
               "post_content": self.request,
               "status": status})


def validate_request(post_content: dict) -> None:
    """Validate User Request"""
    if 'title' not in post_content:
        raise Exception("Title is required")
    if 'body' not in post_content:
        raise Exception("Body is required")
    if len(post_content['body']) > 500:
        raise Exception("Body must be less than 500 characters long")
    if len(post_content['title']) > 64:
        raise Exception("Title must be less than 500 characters long")


def send_to_sqs(sqs_queue_url: str, post_content: dict) -> None:
    """Send User Request to SQS"""
    client = boto3.client('sqs')
    client.send_message(
        QueueUrl=sqs_queue_url,
        MessageBody=json.dumps(post_content)
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
    post_content: dict = json.loads(event['body'])
    logger: Logger = Logger(
        post_content,
        event['requestContext']['identity']['sourceIp']
    )

    # Validate Request
    try:
        validate_request(post_content)
    except Exception as e:
        logger.out(e)
        response["statusCode"] = 400
        response["body"] = json.dumps({"Error": str(e)})
        return response

    # Send to SQS
    post_content['timestamp'] = str(event['requestContext']['requestTime'])
    try:
        send_to_sqs(SQS_QUEUE_URL, post_content)
    except Exception as e:
        logger.out(e)
        response["statusCode"] = 500
        response["body"] = json.dumps({"Error": "Internal Server Error"})
        return response

    logger.out("Success")

    return response
