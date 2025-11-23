import json
import boto3
import os

s3 = boto3.client("s3")
print("Lambda handler loaded")

def lambda_handler(event, context):
    # event is the S3 put event or a manual test event
    records = event.get("Records", [])
    results = []
    for r in records:
        s3_bucket = r.get("s3", {}).get("bucket", {}).get("name")
        s3_key = r.get("s3", {}).get("object", {}).get("key")
        if s3_bucket and s3_key:
            try:
                # read first small bytes of the object as example
                obj = s3.get_object(Bucket=s3_bucket, Key=s3_key)
                body = obj['Body'].read(256).decode('utf-8', errors='replace')
                results.append({"bucket": s3_bucket, "key": s3_key, "preview": body})
            except Exception as e:
                results.append({"bucket": s3_bucket, "key": s3_key, "error": str(e)})
        else:
            results.append({"note": "no s3 record"})
    return {
        "statusCode": 200,
        "body": json.dumps(results)
    }