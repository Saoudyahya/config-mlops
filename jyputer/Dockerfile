FROM jupyter/scipy-notebook:python-3.11

USER root

# ── System deps + JetBrains Mono font ────────────────────────────────────
RUN apt-get update && \
    apt-get install -y --no-install-recommends git curl unzip fonts-open-sans && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/share/fonts/truetype/jetbrains-mono && \
    curl -fsSL "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip" \
    -o /tmp/jbm.zip && \
    unzip -q /tmp/jbm.zip -d /tmp/jbm && \
    cp /tmp/jbm/fonts/ttf/*.ttf /usr/share/fonts/truetype/jetbrains-mono/ && \
    fc-cache -fv && rm -rf /tmp/jbm /tmp/jbm.zip

# ── Python packages ───────────────────────────────────────────────────────
RUN pip install --no-cache-dir \
    dvc dvc-s3 mlflow \
    scikit-learn pandas numpy matplotlib seaborn plotly \
    jupyterlab-git jupyterlab-execute-time ipywidgets ipykernel \
    jlab-enhanced-cell-toolbar && \
    python -m ipykernel install --sys-prefix --name python3 --display-name "Python 3 (UM6P)" && \
    jupyter labextension disable @jupyterlab/cell-toolbar-extension

# ── DVC remote (system-wide, survives PVC home mounts) ────────────────────
RUN mkdir -p /etc/dvc && printf \
    '[core]\n    remote = origin\n["remote \"origin\""]\n    url = s3://um6p-dvc-central\n    endpointurl = https://ceph.um6p.ma\n' \
    > /etc/dvc/config

# ── Theme: overwrite variables.css wherever JupyterLab stores it ─────────
# grep reads the FULL file (no size limit) to find the CSS variable marker.
# Works for conda, pip, and any JupyterLab 3.x / 4.x layout.
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
    done

# ── JupyterLab settings ───────────────────────────────────────────────────
RUN mkdir -p /opt/conda/share/jupyter/lab/settings
COPY overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json

# ── User theme settings (both home and skel for Hub PVC mounts) ──────────
RUN mkdir -p \
    /home/jovyan/.jupyter/lab/user-settings/@jupyterlab/apputils-extension \
    /etc/skel/.jupyter/lab/user-settings/@jupyterlab/apputils-extension

COPY themes.jupyterlab-settings \
    /home/jovyan/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings
COPY themes.jupyterlab-settings \
    /etc/skel/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings

# ── Startup hook (single printf line — no CRLF issues) ───────────────────
RUN printf '#!/bin/bash\nD="${HOME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension"\nF="$D/themes.jupyterlab-settings"\nS="/etc/skel/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings"\n[ -f "$F" ] || { mkdir -p "$D"; cp "$S" "$F"; }\n' \
    > /usr/local/bin/before-notebook.d/00-um6p-settings.sh && \
    chmod +x /usr/local/bin/before-notebook.d/00-um6p-settings.sh

# ── Fix ownership ─────────────────────────────────────────────────────────
RUN chown -R ${NB_UID}:${NB_GID} /home/jovyan

USER ${NB_UID}
WORKDIR /home/${NB_USER}
ENV JUPYTER_ENABLE_LAB=yes
LABEL maintainer="UM6P ML Studio" version="final"