# syntax=docker/dockerfile:1
# ─────────────────────────────────────────────────────────────────────────────
# UM6P ML Studio – JupyterLab Image
#
# Font pre-requisite (run once on your machine, inside the jyputer\ folder):
#   PowerShell:
#     curl -L "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip" -o JetBrainsMono.zip
#     Expand-Archive JetBrainsMono.zip -DestinationPath .\jbm-tmp
#     mkdir fonts
#     Copy-Item .\jbm-tmp\fonts\ttf\*.ttf .\fonts\
#     Remove-Item -Recurse .\jbm-tmp, .\JetBrainsMono.zip
#
# Then: docker build -t saoudyahya/jupyter-researcher:latest .
# ─────────────────────────────────────────────────────────────────────────────
FROM jupyter/scipy-notebook:python-3.11

USER root

# ── System deps ───────────────────────────────────────────────────────────────
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends git fonts-open-sans && \
    rm -rf /var/lib/apt/lists/*

# ── JetBrains Mono (from local fonts/ folder — no network call) ───────────────
COPY fonts/ /usr/share/fonts/truetype/jetbrains-mono/
RUN fc-cache -fv

# ── Python packages ───────────────────────────────────────────────────────────
# NOTE: jlab-enhanced-cell-toolbar is NOT installed — it has no JupyterLab 4
# support (https://github.com/jupyterlab-contrib/jlab-enhanced-cell-toolbar/issues/67)
# and would silently produce zero buttons. We keep the built-in cell toolbar.
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir \
    dvc dvc-s3 mlflow \
    scikit-learn pandas numpy matplotlib seaborn plotly \
    jupyterlab-git jupyterlab-execute-time ipywidgets ipykernel && \
    python -m ipykernel install --sys-prefix \
    --name um6p --display-name "Python 3 (UM6P)" && \
    # ── Purge caches in the same layer ───────────────────────────────────────
    conda clean -afy && \
    find /opt/conda -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null || true && \
    find /opt/conda \( -name '*.pyc' -o -name '*.pyo' \) -delete 2>/dev/null || true && \
    find /opt/conda -type d -name 'tests'    -exec rm -rf {} + 2>/dev/null || true && \
    find /opt/conda -type d -name 'test'     -exec rm -rf {} + 2>/dev/null || true && \
    find /opt/conda -type d -name 'testdata' -exec rm -rf {} + 2>/dev/null || true && \
    rm -rf /tmp/* /var/tmp/*

# ── DVC remote ────────────────────────────────────────────────────────────────
RUN mkdir -p /etc/dvc && printf \
    '[core]\n    remote = origin\n["remote \"origin\""]\n    url = s3://um6p-dvc-central\n    endpointurl = https://ceph.um6p.ma\n' \
    > /etc/dvc/config

# ── Theme CSS ─────────────────────────────────────────────────────────────────
COPY um6p_theme_variables.css /tmp/um6p_variables.css
COPY um6p_components.css      /tmp/um6p_components.css

RUN HITS=$(grep -rl "jp-brand-color1" /opt/conda --include="*.css" 2>/dev/null); \
    echo "[UM6P] CSS files found: ${HITS:-none}"; \
    for f in $HITS; do \
    cp /tmp/um6p_variables.css "$f" && echo "[UM6P] patched $f"; \
    DIR=$(dirname "$f"); \
    cp /tmp/um6p_components.css "$DIR/um6p_components.css"; \
    grep -q "um6p_components" "$DIR/index.css" 2>/dev/null || \
    echo '@import url("./um6p_components.css");' >> "$DIR/index.css" 2>/dev/null || true; \
    done && \
    rm -f /tmp/um6p_variables.css /tmp/um6p_components.css

# ── JupyterLab settings ───────────────────────────────────────────────────────
RUN mkdir -p /opt/conda/share/jupyter/lab/settings
COPY overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json

# ── Per-user theme (home + skel for Hub PVC mounts) ──────────────────────────
RUN mkdir -p \
    /home/jovyan/.jupyter/lab/user-settings/@jupyterlab/apputils-extension \
    /etc/skel/.jupyter/lab/user-settings/@jupyterlab/apputils-extension

COPY themes.jupyterlab-settings \
    /home/jovyan/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings
COPY themes.jupyterlab-settings \
    /etc/skel/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings

# ── Startup hook ──────────────────────────────────────────────────────────────
RUN printf '#!/bin/bash\nD="${HOME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension"\nF="$D/themes.jupyterlab-settings"\nS="/etc/skel/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings"\n[ -f "$F" ] || { mkdir -p "$D"; cp "$S" "$F"; }\n' \
    > /usr/local/bin/before-notebook.d/00-um6p-settings.sh && \
    chmod +x /usr/local/bin/before-notebook.d/00-um6p-settings.sh

RUN chown -R ${NB_UID}:${NB_GID} /home/jovyan

USER ${NB_UID}
WORKDIR /home/${NB_USER}
ENV JUPYTER_ENABLE_LAB=yes
LABEL maintainer="UM6P ML Studio" version="2.0"