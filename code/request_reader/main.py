import os
import json

from helper import RequestTable, Logger


def lambda_handler(event, context):

    REQUEST_TABLE_NAME: str = os.environ.get('REQUEST_TABLE_NAME')

    response: dict = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({"Message": "Sucess"})
    }

    query_params = event.get('queryStringParameters')
    if query_params is None:
        query_params = {
            'last_timestamp': None,
            'flagged': 'false'
        }

    logger = Logger(request=query_params,
                    sender_ip=event['requestContext']['identity']['sourceIp'])

    item_per_page = query_params.get('item_per_page') or 10

    request_table = RequestTable(REQUEST_TABLE_NAME)

    if query_params.get('flagged') == 'true':
        items = request_table.flagged(
            query_params.get('last_timestamp'), item_per_page).items
        response['body'] = json.dumps(items)

        logger.out('success')
        return response

    items = request_table.not_flagged(
        query_params.get('last_timestamp'), item_per_page).items
    response['body'] = json.dumps(items)

    logger.out('success')
    return response
