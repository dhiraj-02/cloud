from flask import Flask, request
import boto3
import os

app = Flask(__name__)

s3 = boto3.client("s3")
BUCKET = os.getenv("S3_BUCKET")

@app.get("/health")
def health():
    return {"status": "content-service OK"}

@app.post("/upload")
def upload():
    file = request.files["file"]
    s3.upload_fileobj(file, BUCKET, file.filename)
    return {"message": "uploaded", "file": file.filename}

app.run(host="0.0.0.0", port=5002)
