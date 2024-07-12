"""Lambda Function to Take in User Input and Send to SQS To be Processed"""

import json


def lambda_handler(event, context):
    """Take In User Input, Send to SQS, Retrun Success Message"""

    # Parse the user content and send to sqs: implement
    print(event)

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
