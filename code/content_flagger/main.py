"""Lambda Function to Filter User Content"""

import os
import json
import boto3
from helper import check_for_flag, EvaluationError


class Logger:
    def __init__(self, request: dict, ip: str = None):
        self.request = request
        self.ip = ip

    def out(self, status: str):
        print({
            "post_content": self.request,
            "status": status})


def send_to_sqs(sqs_queue_url: str, body: dict) -> None:
    """Send Request to SQS"""
    client = boto3.client('sqs')
    client.send_message(
        QueueUrl=sqs_queue_url,
        MessageBody=json.dumps(body)
    )


def send_to_sns(sns_topic_arn: str, body: dict) -> None:
    """Send Request to SNS"""
    client = boto3.client('sns')
    client.publish(
        TopicArn=sns_topic_arn,
        Message=json.dumps(body)
    )


def lambda_handler(event, context):
    """Flag user request and send to SQS"""

    ACCEPTED_SQS_QUEUE_URL: str = os.environ.get('ACCEPTED_SQS_QUEUE_URL')
    REJECTED_SNS_TOPIC_ARN: str = os.environ.get('REJECTED_SNS_TOPIC_ARN')
    MODEL_ID: str = os.environ.get('MODEL_ID')

    response: dict = {
        "statusCode": 200,
        "body": json.dumps({"Message": "Sucess"})
    }

    # Get Request Content
    post_content: dict = json.loads(event['Records'][0]['body'])

    logger: Logger = Logger(post_content)

    try:
        check_for_flag(MODEL_ID, post_content['title'], post_content['body'])
    except EvaluationError as e:    
        send_to_sns(REJECTED_SNS_TOPIC_ARN, post_content)
        logger.out(e)
        return response
    except Exception as e:
        logger.out(e)
        raise Exception("Internal Server Error")

    # not flagged
    send_to_sqs(ACCEPTED_SQS_QUEUE_URL, post_content)

    logger.out("Not Flagged")

    return response
