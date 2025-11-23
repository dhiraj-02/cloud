from flask import Flask, request
from kafka import KafkaProducer
import json
import os

app = Flask(__name__)

producer = KafkaProducer(
    bootstrap_servers=os.getenv("KAFKA_BOOTSTRAP"),
    value_serializer=lambda v: json.dumps(v).encode("utf-8")
)

@app.get("/health")
def health():
    return {"status": "event-producer OK"}

@app.post("/event")
def send_event():
    data = request.json
    producer.send("user-events", data)
    producer.flush()
    return {"status": "event sent"}

app.run(host="0.0.0.0", port=5003)
