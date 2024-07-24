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
    "body": "Request Body",
    "timestamp: "Time of the request",
    "requester_ip": "Requester IP",
}

Flagged Content Output:
{
    "title": "Request Title",
    "body": "Request Body",
    "timestamp: "Time of the request",
    "requester_ip": "Requester IP",
    "flagged_reason": "Reason for the flag"
}

"""

import os
import json
from helper import (check_for_flag,
                    EvaluationError,
                    Logger,
                    send_to_sns,
                    send_to_sqs)


def lambda_handler(event, context):
    """Flag user request and send to SQS"""

    WRITER_SQS_QUEUE_URL: str = os.environ.get('WRITER_SQS_QUEUE_URL')
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
        send_to_sns(REJECTED_SNS_TOPIC_ARN, request_content)
        send_to_sqs(WRITER_SQS_QUEUE_URL, request_content)
        logger.out("Flagged For: " + str(reason))
        return response

    send_to_sqs(WRITER_SQS_QUEUE_URL, request_content)
    logger.out("Not Flagged")
    return response
