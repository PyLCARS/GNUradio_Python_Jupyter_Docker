FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Build arguments for UID/GID mapping
ARG USER_ID=1001
ARG GROUP_ID=1001

# ============================================
# LAYER 1: System packages (rarely changes)
# ============================================
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-venv \
    gnuradio \
    gnuradio-dev \
    curl \
    git \
    vim-tiny \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# ============================================
# LAYER 2: Python virtual environment
# ============================================
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel

# ============================================
# LAYER 3: Core Python dependencies
# ============================================
# Critical: NumPy 1.x required for GNU Radio compatibility
RUN /opt/venv/bin/pip install --no-cache-dir \
    'numpy>=1.24,<2.0' \
    jupyterlab \
    notebook \
    ipykernel \
    ipywidgets \
    'matplotlib>=3.5,<3.9' \
    toml \
    loguru

# ============================================
# LAYER 4: User setup
# ============================================
RUN groupadd -o -g ${GROUP_ID} jovyan && \
    useradd -o -m -s /bin/bash -u ${USER_ID} -g jovyan jovyan

# Create directory structure with proper permissions
RUN mkdir -p /home/jovyan/{notebooks,flowgraphs,scripts,data} \
             /home/jovyan/.local/bin \
             /home/jovyan/.gnuradio/prefs \
             /home/jovyan/.jupyter/templates \
             /home/jovyan/.ipython/profile_default/startup && \
    chown -R jovyan:jovyan /home/jovyan

# Configure GNU Radio for container environment
RUN echo "vmcircbuf_default_factory = gr_vmcircbuf_sysv_shm_factory" > \
    /home/jovyan/.gnuradio/prefs/vmcircbuf_default_factory && \
    chown jovyan:jovyan /home/jovyan/.gnuradio/prefs/vmcircbuf_default_factory

# Also create config for root (used during build verification)
RUN mkdir -p /root/.gnuradio/prefs && \
    echo "vmcircbuf_default_factory = gr_vmcircbuf_sysv_shm_factory" > \
    /root/.gnuradio/prefs/vmcircbuf_default_factory

# ============================================
# LAYER 5: Template system setup
# ============================================
COPY --chown=jovyan:jovyan docker/jupyter_template_system_config.py /home/jovyan/.jupyter/
COPY --chown=jovyan:jovyan docker/templates/gnuradio_notebook_starter_template.json /home/jovyan/.jupyter/templates/

# IPython startup script for GNU Radio bridge
RUN echo 'import sys\n\
import os\n\
import warnings\n\
warnings.filterwarnings("ignore", category=DeprecationWarning)\n\
warnings.filterwarnings("ignore", message="pkg_resources is deprecated")\n\
os.environ["PYTHONUSERBASE"] = "/home/jovyan/.local"\n\
if "/usr/lib/python3/dist-packages" not in sys.path:\n\
    sys.path.append("/usr/lib/python3/dist-packages")\n\
    print("🔗 GNU Radio bridge activated")\n\
try:\n\
    from gnuradio import gr\n\
    print(f"✓ GNU Radio {gr.version()} ready")\n\
except ImportError as e:\n\
    print(f"⚠ GNU Radio issue: {e}")' \
    > /home/jovyan/.ipython/profile_default/startup/00-gnuradio-bridge.py && \
    chown jovyan:jovyan /home/jovyan/.ipython/profile_default/startup/00-gnuradio-bridge.py

# ============================================
# LAYER 6: Project dependencies
# ============================================
COPY config/pyproject.toml /tmp/pyproject.toml
RUN cd /tmp && \
    /opt/venv/bin/pip install --no-cache-dir -e . && \
    rm -rf /tmp/*

# ============================================
# LAYER 7: Jupyter kernel setup
# ============================================
RUN /opt/venv/bin/python -m ipykernel install \
    --name 'python3' \
    --display-name 'Python 3 (GNU Radio)' \
    --prefix /opt/venv && \
    chown -R jovyan:jovyan /opt/venv

# ============================================
# LAYER 8: Build verification
# ============================================
COPY --chown=jovyan:jovyan docker/docker_build_verification_tests.py /tmp/docker_build_verification_tests.py
RUN cd /tmp && \
    /opt/venv/bin/python docker_build_verification_tests.py && \
    rm /tmp/docker_build_verification_tests.py

# ============================================
# LAYER 9: Final configuration
# ============================================
USER jovyan
WORKDIR /home/jovyan

# Environment variables
ENV PYTHONUSERBASE=/home/jovyan/.local \
    PATH="/home/jovyan/.local/bin:/opt/venv/bin:${PATH}" \
    JUPYTER_PATH=/opt/venv/share/jupyter \
    JUPYTER_RUNTIME_DIR=/home/jovyan/.local/share/jupyter/runtime \
    JUPYTER_DATA_DIR=/home/jovyan/.local/share/jupyter

# Jupyter port
EXPOSE 8888

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /opt/venv/bin/jupyter lab list || exit 1

# Default command
CMD ["/opt/venv/bin/jupyter", "lab", \
     "--ip=0.0.0.0", \
     "--port=8888", \
     "--no-browser", \
     "--config=/home/jovyan/.jupyter/jupyter_template_system_config.py", \
     "--ServerApp.token=docker", \
     "--ServerApp.password=", \
     "--ServerApp.allow_origin=*", \
     "--KernelSpecManager.ensure_native_kernel=False"]
