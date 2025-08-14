FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Build args for UID/GID
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
    && rm -rf /var/lib/apt/lists/*

# ============================================
# LAYER 2: Virtual environment setup (stable)
# ============================================
RUN python3 -m venv /opt/venv

# Upgrade pip and install build tools
RUN /opt/venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel

# ============================================
# LAYER 3: Core dependencies (semi-stable)
# ============================================
# Critical: NumPy 1.x for GNU Radio
RUN /opt/venv/bin/pip install --no-cache-dir 'numpy>=1.24,<2.0'

# Core packages that rarely change
RUN /opt/venv/bin/pip install --no-cache-dir \
    jupyterlab \
    notebook \
    ipykernel \
    ipywidgets \
    'matplotlib>=3.5,<3.9' \
    toml \
    loguru

# ============================================
# LAYER 4: User setup (stable)
# ============================================
RUN groupadd -o -g ${GROUP_ID} jovyan && \
    useradd -o -m -s /bin/bash -u ${USER_ID} -g jovyan jovyan

# Create directory structure
RUN mkdir -p /home/jovyan/notebooks \
             /home/jovyan/flowgraphs \
             /home/jovyan/scripts \
             /home/jovyan/data \
             /home/jovyan/.local/bin \
             /home/jovyan/.gnuradio/prefs \
             /home/jovyan/.jupyter/templates \
             /home/jovyan/.ipython/profile_default/startup

# GNU Radio config
RUN echo "vmcircbuf_default_factory = gr_vmcircbuf_sysv_shm_factory" > \
    /home/jovyan/.gnuradio/prefs/vmcircbuf_default_factory

# Also create config for root (used during build verification)
RUN mkdir -p /root/.gnuradio/prefs && \
    echo "vmcircbuf_default_factory = gr_vmcircbuf_sysv_shm_factory" > \
    /root/.gnuradio/prefs/vmcircbuf_default_factory

# ============================================
# LAYER 5: Template system (semi-stable)
# ============================================
# Ensure template directories exist before copying
RUN mkdir -p /home/jovyan/.jupyter/templates

# Copy template system files (will fix ownership later)
COPY jupyter_notebook_config.py /home/jovyan/.jupyter/
COPY gnuradio_base_template.json /home/jovyan/.jupyter/templates/

# IPython startup for GNU Radio bridge
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
    print(f"⚠️ GNU Radio issue: {e}")' \
    > /home/jovyan/.ipython/profile_default/startup/00-gnuradio-bridge.py

# ============================================
# LAYER 6: Project dependencies (changes frequently)
# This layer rebuilds when pyproject.toml changes
# ============================================
COPY pyproject.toml /tmp/pyproject.toml

# Install from pyproject.toml
RUN cd /tmp && \
    /opt/venv/bin/pip install --no-cache-dir -e . && \
    rm -rf /tmp/*

# ============================================
# LAYER 7: Jupyter Kernel Setup
# ============================================
# Create Jupyter kernel with GNU Radio name
RUN /opt/venv/bin/python -m ipykernel install \
    --name 'python3' \
    --display-name 'Python 3 (GNU Radio)' \
    --prefix /opt/venv

# ============================================
# LAYER 8: Fix Ownership
# ============================================
# Set ownership of everything before verification
RUN chown -R jovyan:jovyan /home/jovyan /opt/venv

# ============================================
# LAYER 9: Verification (always runs)
# ============================================
# Copy verification script with correct ownership
COPY --chown=jovyan:jovyan verify_build.py /tmp/verify_build.py

# Run comprehensive verification (fails build if tests fail)
RUN cd /tmp && \
    /opt/venv/bin/python verify_build.py && \
    rm /tmp/verify_build.py

# ============================================
# LAYER 10: Runtime configuration
# ============================================
USER jovyan
WORKDIR /home/jovyan

ENV PYTHONUSERBASE=/home/jovyan/.local
ENV PATH="/home/jovyan/.local/bin:/opt/venv/bin:${PATH}"
ENV JUPYTER_PATH=/opt/venv/share/jupyter
ENV JUPYTER_RUNTIME_DIR=/home/jovyan/.local/share/jupyter/runtime
ENV JUPYTER_DATA_DIR=/home/jovyan/.local/share/jupyter

EXPOSE 8888

CMD ["/opt/venv/bin/jupyter", "lab", \
     "--ip=0.0.0.0", \
     "--port=8888", \
     "--no-browser", \
     "--config=/home/jovyan/.jupyter/jupyter_notebook_config.py", \
     "--ServerApp.token=docker", \
     "--ServerApp.password=", \
     "--ServerApp.allow_origin=*", \
     "--KernelSpecManager.ensure_native_kernel=False"]
