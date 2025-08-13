FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-venv \
    gnuradio \
    gnuradio-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment to avoid conflicts
RUN python3 -m venv /opt/venv

# Install Jupyter in the virtual environment
RUN /opt/venv/bin/pip install --no-cache-dir \
    jupyterlab \
    notebook \
    ipywidgets \
    plotly

# Create jovyan user with UID 1000 (matches most Linux desktop users)
# The fix: explicitly set UID/GID to match common host systems
RUN useradd -m -s /bin/bash -u 1000 -U jovyan && \
    # Give jovyan ownership of the venv
    chown -R jovyan:jovyan /opt/venv

USER jovyan

# Create all working directories
RUN mkdir -p /home/jovyan/notebooks \
             /home/jovyan/flowgraphs \
             /home/jovyan/scripts \
             /home/jovyan/data

WORKDIR /home/jovyan

EXPOSE 8888

# Use the virtual environment's jupyter
CMD ["/opt/venv/bin/jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--ServerApp.token=docker", "--ServerApp.password="]