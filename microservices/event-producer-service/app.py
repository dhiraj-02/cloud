# microservices/event-producer/app.py
from flask import Flask, request
from kafka import KafkaProducer
import json
import os
import sys
import traceback

app = Flask(__name__)

def make_kafka_producer():
    raw_bs = os.environ.get("KAFKA_BOOTSTRAP", "")  # e.g. host1:9094,host2:9094
    # sanitize: split on comma, strip whitespace and quotes, drop empty entries
    bootstrap_list = [h.strip().strip('"').strip("'") for h in raw_bs.split(",") if h.strip()]
    if not bootstrap_list and raw_bs.strip():
        # fallback: use the raw string if splitting produced nothing
        bootstrap_list = [raw_bs.strip()]

    security_protocol = os.environ.get("KAFKA_SECURITY_PROTOCOL", "")
    ssl_cafile = os.environ.get("KAFKA_SSL_CAFILE", None)
    request_timeout_ms = int(os.environ.get("KAFKA_REQUEST_TIMEOUT_MS", "30000"))
    api_version_auto_timeout_ms = int(os.environ.get("KAFKA_API_VERSION_AUTO_TIMEOUT_MS", "30000"))
    retries = int(os.environ.get("KAFKA_RETRIES", "5"))

    kwargs = {
        "bootstrap_servers": bootstrap_list or None,
        "value_serializer": lambda v: json.dumps(v).encode("utf-8"),
        "request_timeout_ms": request_timeout_ms,
        "api_version_auto_timeout_ms": api_version_auto_timeout_ms,
        "retries": retries,
    }

    # Only pass SSL args if set
    if security_protocol:
        kwargs["security_protocol"] = security_protocol
    if ssl_cafile:
        kwargs["ssl_cafile"] = ssl_cafile

    if not kwargs["bootstrap_servers"]:
        raise RuntimeError("KAFKA_BOOTSTRAP is empty or invalid; set KAFKA_BOOTSTRAP env")

    return KafkaProducer(**kwargs)

# create producer at startup and log failures
try:
    producer = make_kafka_producer()
    app.logger.info(f"KafkaProducer created with bootstrap: {os.environ.get('KAFKA_BOOTSTRAP')}")
except Exception:
    app.logger.error("Failed to create KafkaProducer at startup; traceback follows")
    traceback.print_exc(file=sys.stderr)
    # crash fast so K8s shows CrashLoopBackOff and logs are visible
    raise

@app.get("/health")
def health():
    return {"status": "event-producer OK"}

@app.post("/event")
def send_event():
    data = request.json
    producer.send("user-events", data)
    producer.flush()
    return {"status": "event sent"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5003)
