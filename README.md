# Observability with FastAPI, Tempo, and Grafana

## Overview

In this document, we will walk through setting up observability for a FastAPI application using Tempo (a distributed tracing system) and Grafana (a visualization tool). The observability stack consists of:

- **FastAPI**: The web framework for building APIs.
- **Tempo**: A distributed tracing system to collect and store trace data.
- **Grafana**: A data visualization tool to visualize the trace data.

## Prerequisites

- Docker is installed on your system.
- FastAPI application setup.
- Tempo and Grafana Docker images.

## Architecture

This setup includes three main components:

1. **FastAPI Application**:
   - This is where your API logic resides.
   - OpenTelemetry is used to trace requests.

2. **Tempo**:
   - Tempo collects trace data from FastAPI.
   - It exposes an OTLP endpoint (default port 4318) that receives trace data.

3. **Grafana**:
   - Grafana visualizes trace data from Tempo.

## Files

### `main.py`

This is your FastAPI application file. It includes the setup for tracing with OpenTelemetry.

```python
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
```