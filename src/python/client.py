import os
import time
import requests

from opentelemetry import trace

tracer = trace.get_tracer_provider().get_tracer(__name__)

@tracer.start_as_current_span("send_requests")
def send_requests(url):
    try:
        res = requests.get(url)
        print(f"Request to {url}, got {len(res.content)} bytes")
        print(f"Response returned: {res.json()}")
    except Exception as e:
        print(f"Request to {url} failed {e}")


if __name__ == "__main__":
    target = os.getenv("DESTINATION_URL", "http://localhost:8082/rolldice")
    while True:
        send_requests(target)
        time.sleep(5)