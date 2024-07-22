
import unittest
import requests
import subprocess


API_URL = subprocess.run(
    "terraform output api_gateway-invoke_url".split(" "),
    stdout=subprocess.PIPE
).stdout.decode("utf-8").strip()[1:-1] + "/submit_post"



response = requests.post(
    API_URL,
    json={
        "title": "Hello, World!",
        "body": "This is a test post."
    }
)

print(f"Sending test post to {API_URL}")

print(f"Response {response.json()}")

