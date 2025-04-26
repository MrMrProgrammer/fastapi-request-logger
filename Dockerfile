FROM python:3.11-slim

WORKDIR /app

# فقط نیاز داریم پکیج‌ها نصب بشن
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "9002", "--reload"]
