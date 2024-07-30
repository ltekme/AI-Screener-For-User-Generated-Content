import boto3
import re


def valid_email(email: str) -> bool:
    pat = r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,7}\b"
    return re.match(pat, email)


class Logger:
    def __init__(self, request: dict, sender_ip: str):
        self.request = request
        self.sender_ip = sender_ip

    def out(self, status: str) -> dict:
        return {
            "query_string": self.request,
            "sender_ip": self.sender_ip,
            "status": status
        }


class PendingSubscription(Exception):
    pass


class SubscriptionNotFound(Exception):
    pass


class snsTopic:
    def __init__(self, topic_name: str,  region_name: str = "us-east-1"):
        self.client = boto3.client("sns", region_name=region_name)
        self.topic_name = topic_name
        self.subscriptions = self.client.list_subscriptions_by_topic(
            TopicArn=self.topic_name
        )
        self.email_subscribers = filter(
            lambda subscription: subscription["Protocol"] == "email",
            self.subscriptions["Subscriptions"]
        )

    def subscribe(self, email: str) -> None:
        self.client.subscribe(
            TopicArn=self.topic_name,
            Protocol="email",
            Endpoint=email
        )

    def unsubscribe(self, email: str) -> None:
        for subscriber in self.email_subscribers:
            if subscriber["Endpoint"] == email:
                if subscriber["SubscriptionArn"].startswith("PendingConfirmation"):
                    raise PendingSubscription
                self.client.unsubscribe(
                    SubscriptionArn=subscriber["SubscriptionArn"]
                )
                return
        raise SubscriptionNotFound

    @property
    def subscribers(self) -> list[dict]:

        return [{"email": subscriber["Endpoint"], "status": "Subscribed" if subscriber["SubscriptionArn"].startswith("arn") else "Pending Confirmation" } for subscriber in self.email_subscribers]
