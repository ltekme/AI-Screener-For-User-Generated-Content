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
from helper import (Logger,
                    SSM,
                    send_to_sns,
                    send_to_sqs,
                    EvaluationError,
                    check_for_flag,)


def lambda_handler(event, context):
    """Flag user request and send to SQS"""

    WRITER_SQS_QUEUE_URL: str = os.environ.get('WRITER_SQS_QUEUE_URL')
    REJECTED_SNS_TOPIC_ARN: str = os.environ.get('REJECTED_SNS_TOPIC_ARN')
    MODEL_ID: str = os.environ.get('MODEL_ID') or "abc/no-model-id-set"
    SSM_PARAMETER_PREFIX: str = os.environ.get("SSM_PARAMETER_PREFIX")

    response: dict = {
        "statusCode": 200,
        "body": json.dumps({"Message": "Sucess"})
    }

    # Get Request Content
    request_content: dict = json.loads(event['Records'][0]['body'])

    try:
        paramater_store = SSM(SSM_PARAMETER_PREFIX)
    except Exception as reason:
        raise EvaluationError(reason)

    logger: Logger = Logger(request_content)

    try:
        # Always Flag
        if paramater_store.get("always-flag") == "true":
            raise EvaluationError("Always Flag Enabled")

        # Bypass Flagger
        if paramater_store.get("bypass-flagger") == "true":
            send_to_sqs(WRITER_SQS_QUEUE_URL, request_content)
            print(logger.out("Bypassed"))
            return response

        # Invoke Bedrock
        try:
            check_for_flag(
                MODEL_ID.split('/')[1],
                request_content['title'],
                request_content['body'])
        except Exception as reason:
            raise EvaluationError(reason)

        # Not Flagged
        send_to_sqs(WRITER_SQS_QUEUE_URL, request_content)
        print(logger.out("Not Flagged"))
        return response

    # Flagged
    except EvaluationError as reason:
        request_content["flagged_reason"] = str(reason)
        send_to_sns(REJECTED_SNS_TOPIC_ARN, request_content)
        send_to_sqs(WRITER_SQS_QUEUE_URL, request_content)
        logger.out("Flagged For: " + str(reason))
        return response
