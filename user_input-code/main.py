"""Lambda Function to Take in User Input and Send to SQS To be Processed"""

import json

response = {
    "statusCode": 200,
    "headers": {
        "content-type": "application/json"
    },
    "body": json.dumps({"Message": "Hello from Lambda!"})
}


def lambda_handler(event, context):
    """Take In User Input, Send to SQS, Retrun Success Message"""

    # Parse the user content and send to sqs: implement
    print(event)

    return response
