import unittest
import requests
import subprocess


class TestAPIOutput(unittest.TestCase):
    API_URL = subprocess.run(
        "terraform output api_gateway-invoke_url".split(" "),
        stdout=subprocess.PIPE
    ).stdout.decode("utf-8").strip()[1:-1]

    def test_accepted_response(self):
        response = requests.post(
            self.API_URL + "/submit_post",
            json={
                "title": "Hello, World!",
                "body": "I am new to this commumity and I am excited to be here."
            }
        )
        self.assertEqual(response.json(), {"Message": "Success"})
        self.assertEqual(response.status_code, 200)

    def test_rejected_response(self):
        response = requests.post(
            self.API_URL + "/submit_post",
            json={
                "title": "Hello, World!",
                "body": "I hate everyone in this community and I am going to kill them all."
            }
        )
        self.assertEqual(response.json(), {"Message": "Success"})
        self.assertEqual(response.status_code, 200)


if __name__ == '__main__':
    unittest.main()
