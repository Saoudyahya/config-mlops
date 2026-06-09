# mlflow/Dockerfile
FROM ghcr.io/mlflow/mlflow:v3.10.1

RUN pip install --no-cache-dir \
    "mlflow[auth]" \
    psycopg2-binary \
    boto3

# Verify install
RUN python -c "import mlflow; import psycopg2; import boto3; print('OK')"