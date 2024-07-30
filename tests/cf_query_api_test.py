import unittest
import requests
import subprocess
import json

# <cf-dist>/api/dynamo_query?flagged=true&last_timestamp=2024-07-29T13:31:28&item_per_page=100


class TestAPIOutput(unittest.TestCase):
    TF_OUTPUT = subprocess.run(
        "terraform output web-interafce-cloudfront-domain-name".split(" "),
        stdout=subprocess.PIPE
    ).stdout.decode("utf-8").strip()[1:-1]
    API_URL = f"https://{TF_OUTPUT}/api"

    def test_no_param(self):
        response = requests.get(self.API_URL + "/dynamo_query")
        print(response.json())
        self.assertIn('[', str(response.json()))
        self.assertEqual(response.status_code, 200)

    def test_flagged_param(self):
        response = requests.get(self.API_URL + "/dynamo_query?flagged=true")
        print(response.json())
        self.assertIn('[', str(response.json()))
        self.assertEqual(response.status_code, 200)

    def test_not_flagged_param(self):
        response = requests.get(self.API_URL + "/dynamo_query?flagged=false")
        print(response.json())
        self.assertIn('[', str(response.json()))
        self.assertEqual(response.status_code, 200)

    def test_last_timestamp_param(self):
        response = requests.get(
            self.API_URL + "/dynamo_query?last_timestamp=2024-07-29T13:31:28")
        print(response.json())
        self.assertIn('[', str(response.json()))
        self.assertEqual(response.status_code, 200)

    def test_item_per_page_param(self):
        item_count = 20
        response = requests.get(
            self.API_URL + f"/dynamo_query?item_per_page={item_count}")
        print(response.json())
        self.assertIn('[', str(response.json()))
        self.assertLessEqual(len(response.json()), item_count)
        self.assertEqual(response.status_code, 200)


if __name__ == '__main__':
    unittest.main()
