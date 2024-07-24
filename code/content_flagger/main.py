"""Lambda Function to Flag User Content

Expected Input Body:
{
    "title": "Request Title",
    "body": "Request Body"
    "timestamp: "Time of the request"
    "requester_ip": "Requester IP"
}

Environment Variables:
- ACCEPTED_SQS_QUEUE_URL: URL of the SQS Queue to send the accepted request to
- REJECTED_SNS_TOPIC_ARN: ARN of the SNS Notification Topic to send the rejected request to
- MODEL_ID: ID of the bedrock model to used for flagging

Logger: input user request content
- out: Returns a dictionary with the request_content and status
    status: When the request content is flagged, the reason for the flag would be stated. Otherwise, "Not Flagged". If any other error accored. The Error will be returned.
    {
        "request_content": {
            "title": "Request Title",
            "body": "Request Body"
        },
        "status": ""
    }

Not Flagged Content Output:
{
    "title": "Request Title",
    "body": "Request Body"
    "timestamp: "Time of the request"
    "requester_ip": "Requester IP"
}
"""

import os
import json
import boto3
from helper import check_for_flag, EvaluationError


class Logger:
    def __init__(self, request: dict):
        self.request = request

    def out(self, status: str) -> dict:
        return {
            "request_content": self.request,
            "status": {status}
        }


def send_to_sqs(sqs_queue_url: str, body: dict) -> None:
    """Send Request to SQS"""
    client = boto3.client('sqs')
    client.send_message(
        QueueUrl=sqs_queue_url,
        MessageBody=json.dumps(body)
    )


def send_to_sns(sns_topic_arn: str, body: dict, title: str) -> None:
    """Send Request to SNS"""
    client = boto3.client('sns')
    subject = title or "AWS Notification Message"
    client.publish(
        subject=subject,
        TopicArn=sns_topic_arn,
        Message=json.dumps(body)
    )


def lambda_handler(event, context):
    """Flag user request and send to SQS"""

    ACCEPTED_SQS_QUEUE_URL: str = os.environ.get('ACCEPTED_SQS_QUEUE_URL')
    REJECTED_SQS_QUEUE_URL: str = os.environ.get('REJECTED_SQS_QUEUE_URL')
    REJECTED_SNS_TOPIC_ARN: str = os.environ.get('REJECTED_SNS_TOPIC_ARN')
    MODEL_ID: str = os.environ.get('MODEL_ID')

    response: dict = {
        "statusCode": 200,
        "body": json.dumps({"Message": "Sucess"})
    }

    # Get Request Content
    request_content: dict = json.loads(event['Records'][0]['body'])

    logger: Logger = Logger(request_content)

    try:
        check_for_flag(
            MODEL_ID, request_content['title'], request_content['body'])

    except EvaluationError as reason:
        request_content['flagged_reason'] = str(reason)

        try:
            send_to_sns(REJECTED_SNS_TOPIC_ARN, request_content)
        except Exception as e:
            print(logger.out(e))
            response["statusCode"] = 500
            response["body"] = json.dumps({"Error": "Internal Server Error"})
            return response

        try:
            send_to_sqs(REJECTED_SQS_QUEUE_URL, request_content)
        except Exception as e:
            print(logger.out(e))
            response["statusCode"] = 500
            response["body"] = json.dumps({"Error": "Internal Server Error"})
            return response

        print(logger.out(f'Flagged For: {reason}'))
        return response

    except Exception as e:
        print(logger.out(e))
        response["statusCode"] = 500
        response["body"] = json.dumps({"Error": "Internal Server Error"})
        return response

    # not flagged
    try:
        send_to_sqs(ACCEPTED_SQS_QUEUE_URL, request_content)
    except Exception as e:
        print(logger.out(e))
        response["statusCode"] = 500
        response["body"] = json.dumps({"Error": "Internal Server Error"})
        return response

    print(logger.out("Not Flagged"))

    return response
