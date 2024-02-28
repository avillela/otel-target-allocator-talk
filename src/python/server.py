import logging
from random import randint
from flask import Flask

from opentelemetry import trace, metrics

app = Flask(__name__)
logging.getLogger().setLevel(logging.DEBUG)

@app.route("/rolldice")
def roll_dice():
    logging.getLogger().debug("This is a log message associated to an auto-instrumented span.")
    res = ""
    try:
        res = str(do_roll())
    except Exception as e:
        res = "0"
        with tracer.start_as_current_span("even_number") as span:
            span.record_exception(e)
            print(f"PRINT: Returning value {res} from exception {str(e)}")
            logging.getLogger().error("Uh-oh. We have an exception. This log message only prints if this span is created. The span is only created if an exception is thrown.")
        
    return res

def do_roll():
    res = randint(1, 6)

    # By default, record_exception is True. If we set it to false, it still creates a Span Event, but not one with the full exception.
    with tracer.start_as_current_span("do_roll", set_status_on_exception=True) as span:
        span = trace.get_current_span()
        span.set_attribute("roll.value", res)
        
        # Add attributes for span event
        attributes = {}
        attributes["key1"] = "value1"
        attributes["key2"] = "value2"

        span.add_event("This is a span event", attributes=attributes)

        logging.getLogger().info("This is a log message! The span may err out, but this log message is independent of whether or not the span errs out.")

        request_counter.add(1)
        
        if (res % 2 == 0):
            raise Exception("Divisible by 2!")

    return res

if __name__ == "__main__":
    # Init tracer
    tracer = trace.get_tracer_provider().get_tracer(__name__)

    # Init metrics + create a counter instrument
    meter = metrics.get_meter_provider().get_meter(__name__)
    request_counter = meter.create_counter(name="request_counter", description="Number of requests", unit="1")

    app.run(host="0.0.0.0", port=8082, debug=True, use_reloader=False)