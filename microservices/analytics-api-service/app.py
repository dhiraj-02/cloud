from flask import Flask
import boto3
import os

app = Flask(__name__)

ddb = boto3.resource("dynamodb")
table = ddb.Table(os.getenv("DYNAMODB_TABLE"))

@app.get("/health")
def health():
    return {"status": "analytics-api OK"}

@app.get("/results/<courseId>")
def results(courseId):
    resp = table.get_item(Key={"courseId": courseId})
    return resp.get("Item", {})

app.run(host="0.0.0.0", port=5005)
