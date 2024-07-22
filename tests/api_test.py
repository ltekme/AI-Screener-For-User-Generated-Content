import unittest
import requests
import subprocess


class TestAPIOutput(unittest.TestCase):
    API_URL = subprocess.run(
        "terraform output api_gateway-invoke_url".split(" "),
        stdout=subprocess.PIPE
    ).stdout.decode("utf-8").strip()[1:-1]

    def test_sucess_response(self):
        response = requests.post(
            self.API_URL + "/submit_post",
            json={
                "title": "Hello, World!",
                "body": "This is a test post."
            }
        )
        self.assertEqual(response.json(), {"Message": "Success"})
        self.assertEqual(response.status_code, 200)

    def test_error_too_long(self):
        response = requests.post(
            self.API_URL + "/submit_post",
            json={
                "title": "Hello, World!",
                "body": "a" * 502
            }
        )
        self.assertEqual(response.json(), {
                         "Error": "Body must be less than 500 characters long"})
        self.assertEqual(response.status_code, 400)

    def test_error_no_title(self):
        response = requests.post(
            self.API_URL + "/submit_post",
            json={
                "body": "This is a test post."
            }
        )
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.json(), {"Error": "Title is required"})

    def test_error_no_body(self):
        response = requests.post(
            self.API_URL + "/submit_post",
            json={
                "title": "Hello, World!"
            }
        )
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.json(), {"Error": "Body is required"})


if __name__ == '__main__':
    unittest.main()
