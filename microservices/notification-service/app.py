from flask import Flask
import boto3
import os

app = Flask(__name__)

sqs = boto3.client("sqs")
sns = boto3.client("sns")

QUEUE_URL = os.getenv("SQS_URL")
TOPIC_ARN = os.getenv("SNS_TOPIC")

@app.get("/health")
def health():
    return {"status": "notification-service OK"}

@app.get("/poll")
def poll():
    msgs = sqs.receive_message(
        QueueUrl=QUEUE_URL,
        MaxNumberOfMessages=5
    )
    return msgs

@app.post("/notify")
def send():
    sns.publish(
        TopicArn=TOPIC_ARN,
        Message="Notification Test"
    )
    return {"status": "sent"}

app.run(host="0.0.0.0", port=5004)
