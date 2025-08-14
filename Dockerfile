FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Build args for UID/GID (defaults to 1001 to avoid conflicts)
ARG USER_ID=1001
ARG GROUP_ID=1001

RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-venv \
    gnuradio \
    gnuradio-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment to avoid conflicts
# DO NOT USE --system-site-packages! This isolation is CRITICAL for pyzmq conflict resolution
RUN python3 -m venv /opt/venv

# Upgrade pip and install build tools
RUN /opt/venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel

# CRITICAL: Install NumPy 1.x for GNU Radio compatibility
RUN /opt/venv/bin/pip install --no-cache-dir 'numpy>=1.24,<2.0'

# Install matplotlib separately to avoid conflicts with system version
# Uninstall any system matplotlib imports first
RUN /opt/venv/bin/pip install --no-cache-dir --force-reinstall --no-deps 'matplotlib>=3.5,<3.9' && \
    /opt/venv/bin/pip install --no-cache-dir 'matplotlib>=3.5,<3.9'

# Install other packages with version constraints for numpy 1.x compatibility
RUN /opt/venv/bin/pip install --no-cache-dir \
    jupyterlab \
    notebook \
    ipykernel \
    ipywidgets \
    plotly \
    'scipy>=1.10,<1.14' \
    'pandas>=2.0,<2.2'

# Install UV for fast package management
RUN /opt/venv/bin/pip install --no-cache-dir uv

# Copy requirements files if they exist
COPY requirements*.txt pyproject.toml* /tmp/

# Install from requirements.txt if it exists (respecting numpy constraint)
RUN if [ -f /tmp/requirements.txt ]; then \
        echo "Installing from requirements.txt..."; \
        /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt; \
    fi

# Clean up temp files
RUN rm -rf /tmp/requirements*.txt /tmp/pyproject.toml*

# Create proper Jupyter kernel
RUN /opt/venv/bin/python -m ipykernel install \
    --name 'python3' \
    --display-name 'Python 3 (GNU Radio)' \
    --prefix /opt/venv

# Create jovyan user with -o flag for non-unique UID/GID
RUN groupadd -o -g ${GROUP_ID} jovyan && \
    useradd -o -m -s /bin/bash -u ${USER_ID} -g jovyan jovyan

# Set ownership
RUN chown -R jovyan:jovyan /home/jovyan && \
    chown -R jovyan:jovyan /opt/venv

# Switch to jovyan user
USER jovyan

# Set environment variables
ENV PYTHONUSERBASE=/home/jovyan/.local
ENV PATH="/home/jovyan/.local/bin:/opt/venv/bin:${PATH}"
ENV JUPYTER_PATH=/opt/venv/share/jupyter
ENV JUPYTER_RUNTIME_DIR=/home/jovyan/.local/share/jupyter/runtime
ENV JUPYTER_DATA_DIR=/home/jovyan/.local/share/jupyter

# Create working directories including GNU Radio config
RUN mkdir -p /home/jovyan/notebooks \
             /home/jovyan/flowgraphs \
             /home/jovyan/scripts \
             /home/jovyan/data \
             /home/jovyan/.local/bin \
             /home/jovyan/.gnuradio/prefs

# Create GNU Radio preference file to avoid warning
RUN echo "vmcircbuf_default_factory = gr_vmcircbuf_sysv_shm_factory" > /home/jovyan/.gnuradio/prefs/vmcircbuf_default_factory

# Create IPython startup script for automatic GNU Radio bridge
RUN mkdir -p /home/jovyan/.ipython/profile_default/startup && \
    echo 'import sys\n\
import os\n\
import warnings\n\
\n\
# Suppress deprecation warnings\n\
warnings.filterwarnings("ignore", category=DeprecationWarning)\n\
warnings.filterwarnings("ignore", message="pkg_resources is deprecated")\n\
\n\
# Set environment\n\
os.environ["PYTHONUSERBASE"] = "/home/jovyan/.local"\n\
\n\
# Add GNU Radio to path\n\
if "/usr/lib/python3/dist-packages" not in sys.path:\n\
    sys.path.append("/usr/lib/python3/dist-packages")\n\
    print("🔗 GNU Radio bridge activated")\n\
\n\
# Test GNU Radio\n\
try:\n\
    from gnuradio import gr\n\
    print(f"✓ GNU Radio {gr.version()} ready")\n\
except ImportError as e:\n\
    print(f"⚠️  GNU Radio issue: {e}")\n\
\n\
# Note about package installation\n\
print("📦 Install packages with: !pip install package_name (no --user needed)")' \
    > /home/jovyan/.ipython/profile_default/startup/00-gnuradio-bridge.py

# Create simple test script
RUN echo '#!/opt/venv/bin/python\n\
import sys\n\
sys.path.append("/usr/lib/python3/dist-packages")\n\
from gnuradio import gr\n\
print(f"GNU Radio {gr.version()} works!")' \
    > /home/jovyan/test_gr.py && \
    chmod +x /home/jovyan/test_gr.py

WORKDIR /home/jovyan

EXPOSE 8888

CMD ["/opt/venv/bin/jupyter", "lab", \
     "--ip=0.0.0.0", \
     "--port=8888", \
     "--no-browser", \
     "--ServerApp.token=docker", \
     "--ServerApp.password=", \
     "--ServerApp.allow_origin=*", \
     "--KernelSpecManager.ensure_native_kernel=False"]
