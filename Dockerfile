# Stage 1 - build dependencies
FROM python:3.10-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Stage 2 - runtime
FROM python:3.10-slim
WORKDIR /app
COPY --from=builder /usr/local /usr/local
COPY . .
CMD ["python", "app.py"]
