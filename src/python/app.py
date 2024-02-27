import random
import time
from prometheus_client import start_http_server, Counter

some_counter = Counter(name="some_counter", documentation="Sample counter")

def main() -> None:
    while True:
        random_sleep_time = random.randint(1, 20)
        print(f"Sleeping for {random_sleep_time} seconds", flush=True)
        time.sleep(random_sleep_time)
        some_counter.inc()

if __name__ == "__main__":
    start_http_server(port=8080)
    main()