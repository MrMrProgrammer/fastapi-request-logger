from fastapi import FastAPI
import time
import random

# ---- OpenTelemetry imports ----
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.trace import set_tracer_provider, get_tracer

# ---- FastAPI app ----
app = FastAPI()

# ---- OpenTelemetry setup ----
provider = TracerProvider()
set_tracer_provider(provider)

otlp_exporter = OTLPSpanExporter(
    endpoint="http://tempo:4318/v1/traces"  # آدرس otel-collector یا tempo
)
processor = BatchSpanProcessor(otlp_exporter)
provider.add_span_processor(processor)

# فعال‌سازی auto-instrumentation برای FastAPI
FastAPIInstrumentor.instrument_app(app)

# tracer دستی برای ساخت spanهای بیشتر
tracer = get_tracer(__name__)

# ---- API endpoints ----

@app.get("/simple")
def simple_endpoint():
    return {"message": "Hello, this is a simple endpoint!"}

@app.get("/delayed")
def delayed_endpoint():
    with tracer.start_as_current_span("random-delay"):
        delay = random.uniform(0.5, 2.0)

        with tracer.start_as_current_span("sleeping"):
            time.sleep(delay)

        return {"message": f"Response after {delay:.2f} seconds delay"}
