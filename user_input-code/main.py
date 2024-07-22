"""Lambda Function to Vlidate Requset and Send to SQS"""

import json
import os
import boto3

SQS_QUEUE_URL = os.environ.get('SQS_QUEUE_URL')

response = {
    "statusCode": 200,
    "headers": {
        "content-type": "application/json"
    },
    "body": json.dumps({"Message": "Sucess"})
}


class ValidationError(Exception):
    pass


def validate_request(post_content: dict) -> None:
    """Validate User Request"""
    if 'title' not in post_content:
        raise ValidationError("Title is required")
    if 'body' not in post_content:
        raise ValidationError("Body is required")
    if len('body') > 500:
        raise ValidationError("Body must be less than 500 characters long")
    return


def send_to_sqs(post_content: dict) -> None:
    """Send User Request to SQS"""
    client = boto3.client('sqs')
    client.send_message(
        QueueUrl=SQS_QUEUE_URL,
        MessageBody=json.dumps(post_content)
    )
    return


def lambda_handler(event, context):
    """Validate User Request and Send to SQS"""

    # Check Paramaters
    if SQS_QUEUE_URL is None or SQS_QUEUE_URL == "":
        response["statusCode"] = 500
        response["body"] = json.dumps({"Error": "SQS_QUEUE_URL is not set"})
        return response

    # Get User Request
    post_content: dict = json.loads(event['body'])

    # Validate Request
    try:
        validate_request(post_content)
    except ValidationError as e:
        response["statusCode"] = 400
        response["body"] = json.dumps({"Error": str(e)})
        return response

    # Send to SQS
    try:
        send_to_sqs(post_content)
    except Exception as e:
        print(f"SQS_FUNCTION_ERROR: {e}")
        response["statusCode"] = 500
        response["body"] = json.dumps(
            {"Error": "Something Went Wrong, Check Logs"})
        return response

    return response
