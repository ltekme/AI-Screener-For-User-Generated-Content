import boto3
import json



class Logger:
    def __init__(self, request: dict):
        self.request = request

    def out(self, status: str):
        return {
            "request_content": self.request,
            "status": status
        }

class ValidationError(Exception):
    pass

def validate_request(request_content: dict) -> None:
    """Validate User Request"""
    if 'title' not in request_content or len(request_content['title']) == 0:
        raise ValidationError("Title is required")
    if 'body' not in request_content or len(request_content['body']) == 0:
        raise ValidationError("Body is required")
    if len(request_content['body']) > 500:
        raise ValidationError("Body must be less than 500 characters long")
    if len(request_content['title']) > 64:
        raise ValidationError("Title must be less than 500 characters long")


def send_to_sqs(sqs_queue_url: str, request_content: dict) -> None:
    """Send User Request to SQS"""
    client = boto3.client('sqs')
    client.send_message(
        QueueUrl=sqs_queue_url,
        MessageBody=json.dumps(request_content)
    )
