FROM apache/airflow:3.1.0-python3.12

USER root
RUN apt-get update && \
    apt-get install -y git --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER airflow
RUN pip install --no-cache-dir \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-3.0.0/constraints-3.12.txt" \
    "dvc[s3]" \
    boto3 \
    mlflow \
    evidently \
    opentelemetry-exporter-otlp-proto-http