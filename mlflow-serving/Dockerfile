# harbor.local.um6p.ma/infra/mlflow-serve:3.10.1-py310
FROM ghcr.io/mlflow/mlflow:v3.10.1

# System deps — done once at build time, not at pod startup
RUN apt-get update -qq && apt-get install -y -qq libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Pin the full grpc/protobuf/mlserver stack — same versions you have in the DAG
RUN pip install --no-cache-dir \
    'protobuf>=4.25.3,<5.0.0' \
    'grpcio>=1.62.0,<1.63.0' \
    'mlserver==1.3.5' \
    'mlserver-mlflow==1.3.5' \
    'uvloop<0.22'

# Apply the metadata.py patch at build time too
RUN sed -i \
    's/enumerate(schema[.]inputs)/enumerate((schema and schema.inputs) or [])/g' \
    $(python3 -c 'import mlserver_mlflow.metadata as m; print(m.__file__)') \
    && sed -i \
    's/enumerate(schema[.]outputs)/enumerate((schema and schema.outputs) or [])/g' \
    $(python3 -c 'import mlserver_mlflow.metadata as m; print(m.__file__)')