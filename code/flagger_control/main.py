import os
import json

from helper import Logger, SSM


def lambda_handler(event, context):

    SSM_PARAMETER_PREFIX: str = os.environ.get("SSM_PARAMETER_PREFIX")

    response: dict = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({"Message": "Paramaters Set"})
    }

    request_methoad: str = event["httpMethod"]
    request_ip: str = event["requestContext"]["identity"]["sourceIp"]

    logger = Logger(**{
        "request": {
            "request_methoad": request_methoad,
            "request_body": event.get("body")
        },
        "sender_ip": request_ip
    })

    ssm = SSM(SSM_PARAMETER_PREFIX)

    # Get all values
    if request_methoad == "GET":
        try:
            all_params = ssm.get_all_values()
            response["body"] = json.dumps(all_params)
            print(logger.out(f"Get All Values: {all_params}"))
            return response
        except ValueError as e:
            response["statusCode"] = 500
            response["body"] = json.dumps({"Error": str(e)})
            print(logger.out(f"Error Getting All Values: {str(e)}"))
            return response

    # Set parameters
    if request_methoad == "POST":

        # Try load json
        try:
            request_body: dict = json.loads(event["body"])
        except:
            response["statusCode"] = 400
            response["body"] = json.dumps({"Error": "Mailformed json body"})
            return response

        # Case for no parameters in request
        if "bypass_flagger" not in request_body and "always_flag" not in request_body:
            response["statusCode"] = 400
            response["body"] = json.dumps({
                "Error": "Invalid request body"})
            return response

        # Set parameters always_flag
        if "always_flag" in request_body:
            if request_body["always_flag"] not in ["true", "false"]:
                response["statusCode"] = 400
                response["body"] = json.dumps({
                    "Error": "Invalid always_flag value"})
                return response

            try:
                ssm.always_flag = True if request_body["always_flag"] == "true" else False
            except ValueError as e:
                response["statusCode"] = 400
                response["body"] = json.dumps({"Error": str(e)})
                print(logger.out(f"Error Setting always_flag: {str(e)}"))
                return response

            print(logger.out("Set always_flag"))

        # Set parameters bypass_flagger
        if "bypass_flagger" in request_body:
            if request_body["bypass_flagger"] not in ["true", "false"]:
                response["statusCode"] = 400
                response["body"] = json.dumps({
                    "Error": "Invalid bypass_flagger value"})
                return response

            try:
                ssm.bypass_flagger = True if request_body["bypass_flagger"] == "true" else False
            except ValueError as e:
                response["statusCode"] = 400
                response["body"] = json.dumps({
                    "Error": str(e)})
                print(logger.out(f"Error Setting bypass_flagger: {str(e)}"))
                return response
            print(logger.out("Set bypass_flagger"))

        # Success
        print(logger.out("Success"))
        return response

    # Invalid Request: Invalid HTTP Method
    response["statusCode"] = 405
    response["body"] = json.dumps({"Error": "Invalid HTTP Method"})
    print(logger.out("Invalid HTTP Method"))
    return response
