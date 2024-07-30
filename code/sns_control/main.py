import os
import json

from helper import Logger, snsTopic, valid_email, SubscriptionNotFound, PendingSubscription


def lambda_handler(event, context):

    NOTIFY_SNS_TOPIC: str = os.environ.get("NOTIFY_SNS_TOPIC")

    response: dict = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({"Message": "Sucess"})
    }

    request_methoad: str = event["httpMethod"]
    request_ip: str = event["requestContext"]["identity"]["sourceIp"]

    logger = Logger(**{
        "request": {
            "request_methoad": request_methoad,
            "request_body": event.get("body"),
            "query_params": event.get("queryStringParameters")
        },
        "sender_ip": request_ip
    })

    # Get all subscribers
    if request_methoad == "GET":
        sns_topic = snsTopic(NOTIFY_SNS_TOPIC)
        response["body"] = json.dumps(sns_topic.subscribers)
        print(logger.out("Get all subscribers"))
        return response

    # Subscribe email to SNS Topic
    if request_methoad == "POST":

        # Try load json
        try:
            request_body: dict = json.loads(event["body"])
        except:
            response["statusCode"] = 400
            response["body"] = json.dumps({"Error": "Mailformed json body"})
            return response

        # Invalid Request: body without email
        if request_body.get("email") is None or request_body.get("email") == "":
            response["statusCode"] = 400
            response["body"] = json.dumps(
                {"Error": "Email is required"})
            print(logger.out("Email is required"))
            return response

            # Invalid Request: Email is invalid
        if not valid_email(request_body.get("email")):
            response["statusCode"] = 400
            response["body"] = json.dumps(
                {"Error": "Invalid email address"})
            print(logger.out("Invalid email address"))
            return response

        sns_topic = snsTopic(NOTIFY_SNS_TOPIC)
        sns_topic.subscribe(request_body.get("email"))
        print(logger.out("Email subscribed successfully"))
        return response

    # Unsubscribe email from SNS Topic
    if request_methoad == "DELETE":

        query_params: dict = event.get("queryStringParameters") or {
            "email": None}

        # Invalid Request: query without email
        if query_params.get("email") is None or query_params.get("email") == "":
            response["statusCode"] = 400
            response["body"] = json.dumps(
                {"Error": "Email is required"})
            print(logger.out("Email is required"))
            return response

        # Invalid Request: Email is invalid
        if not valid_email(query_params.get("email")):
            response["statusCode"] = 400
            response["body"] = json.dumps(
                {"Error": "Invalid email address"})
            print(logger.out("Invalid email address"))
            return response

        sns_topic = snsTopic(NOTIFY_SNS_TOPIC)
        try:
            sns_topic.unsubscribe(query_params.get("email"))
        except SubscriptionNotFound:
            response["statusCode"] = 400
            response["body"] = json.dumps(
                {"Error": "Subscription not found"})
            print(logger.out("Subscription not found"))
            return response
        except PendingSubscription:
            response["statusCode"] = 400
            response["body"] = json.dumps(
                {"Error": "Subscription is pending confirmation"})
            print(logger.out("Subscription is pending confirmation"))
            return response

        response["body"] = json.dumps(
            {"Message": "Email unsubscribed successfully"})
        print(logger.out("Email unsubscribed successfully"))
        return response

    # Invalid Request: Invalid HTTP Method
    response["statusCode"] = 405
    response["body"] = json.dumps({"Error": "Invalid HTTP Method"})
    print(logger.out("Invalid HTTP Method"))
    return response
