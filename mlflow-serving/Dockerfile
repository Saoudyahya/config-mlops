# harbor.local.um6p.ma/infra/mlflow-serve:3.10.1-py310
FROM ghcr.io/mlflow/mlflow:v3.10.1

RUN apt-get update -qq && apt-get install -y -qq libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# 1. Base tools and mlserver core
RUN pip install --no-cache-dir \
    'protobuf>=4.25.3,<5.0.0' \
    'grpcio>=1.62.0,<1.63.0' \
    'mlserver==1.3.5' \
    'mlserver-mlflow==1.3.5' \
    'uvloop<0.22'

# 2. Heavy ML Frameworks (LightGBM, XGBoost)
RUN pip install --no-cache-dir \
    'lightgbm>=4.0.0' \
    'xgboost>=2.0.0'

# 3. Heavy ML Frameworks (CatBoost, FLAML)
RUN pip install --no-cache-dir \
    'catboost>=1.2.0' \
    'flaml>=2.0.0'

# 4. Standard Python ML/Data Libraries
RUN pip install --no-cache-dir \
    'scikit-learn>=1.4.0' \
    'numpy>=1.26.0' \
    'pandas>=2.0.0' \
    'scipy>=1.11.0' \
    'cloudpickle>=2.2.0' \
    'psutil>=5.9.0' \
    'lz4>=4.3.0' \
    'pyarrow>=14.0.0'

RUN sed -i \
    's/enumerate(schema[.]inputs)/enumerate((schema and schema.inputs) or [])/g' \
    $(python3 -c 'import mlserver_mlflow.metadata as m; print(m.__file__)') \
    && sed -i \
    's/enumerate(schema[.]outputs)/enumerate((schema and schema.outputs) or [])/g' \
    $(python3 -c 'import mlserver_mlflow.metadata as m; print(m.__file__)')