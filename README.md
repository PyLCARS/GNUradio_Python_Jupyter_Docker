# GNU Radio Jupyter Docker Environment

This is a Docker environment that seamlessly integrates GNU Radio with JupyterLab, by dealing with the complex compatibility challenges through virtual environment isolation and providing an automatic notebook template system for rapid SDR development.

## 🎯 Key Challenges Solved

### The Core Integration Problem
GNU Radio (from Ubuntu packages) and Jupyter (from pip) have fundamentally incompatible dependencies:
- **pyzmq conflict**: System GNU Radio requires one version, Jupyter requires another
- **NumPy version lock**: GNU Radio is compiled against NumPy 1.x, incompatible with NumPy 2.x
- **Python path isolation**: System packages vs. virtual environment packages need careful bridging

### Integration Solution Architecture
```
System Python (/usr/bin/python3)
├── GNU Radio 3.10.9.2 (apt packages)
├── System pyzmq (required by GNU Radio)
└── NumPy 1.x (system version)

Virtual Environment (/opt/venv) - ISOLATED
├── JupyterLab (latest)
├── Different pyzmq (Jupyter's version)
├── NumPy 1.x (pinned for compatibility)
└── All user packages

Bridge: IPython startup script adds system packages to path
Result: Both GNU Radio and Jupyter work perfectly together
```

## 🚀 Quick Start

```bash
# Build the Docker image
./gnuradio_jupyter_docker_manager.sh build

# Start the container (auto-finds available port if 8888 is taken)
./gnuradio_jupyter_docker_manager.sh start

# Access JupyterLab
http://localhost:8888/lab?token=docker
```

**Every new notebook automatically includes GNU Radio setup!** No manual configuration needed.

## 🚀 Future Roadmap

**Coming Soon:**
- **Hardware Support**: RTL-SDR, HackRF, USRP device passthrough
- **GNU Radio from Source**: Rebuild to remove NumPy 1.x restrictions
- **OOT Modules**: gr-satellites, gr-inspector, and more
- **Educational Platform**: 
  - Interactive API documentation as notebooks
  - Coherent systems examples from textbooks
  - Specialized constellation/communications plotting tools
- **Extended Libraries**: CommPy, scikit-rf, pyadi-iio for complete SDR toolkit

## 📋 Prerequisites

- Docker installed and running
- Linux host (tested on Ubuntu)
- ~4GB disk space for Docker image
- Port 8888 available (or script will find another)

## 📊 Comparison with Other Solutions

| Solution | Has Jupyter? | GNU Radio Works? | Conflict Resolution | Auto Templates | Container-ized | Size |
|----------|-------------|------------------|-------------------|----------------|----------------|------|
| **This Project** | ✅ Full JupyterLab | ✅ Via bridge | ✅ Elegant venv isolation | ✅ Yes! | ✅ Docker | ~3.5GB |
| **GNU Radio Docker** | ❌ No | ✅ Yes | N/A | ❌ No | ✅ Docker | ~2GB |
| **Radioconda** | ✅ Yes | ✅ Yes | ⚠️ Conda magic | ❌ No | ❌ Conda env | ~6GB+ |
| **Arch AUR** | ❌ User problem | ✅ Yes | ❌ System conflicts | ❌ No | ❌ System pkg | Varies |

**Unique Features of This Solution:**
- **solution** that properly integrates Jupyter + GNU Radio without Conda
- **Automatic notebook templates** with GNU Radio setup (unique feature)
- **Build verification** ensures working images
- **Multiple variants** support (dev/test/prod)
- **Optimized layer caching** for fast rebuilds (~2 min for dependency changes)

## 🏗️ Technical Architecture

### Critical Design Decisions

1. **Virtual Environment Isolation**
   - `/opt/venv` completely isolated from system Python
   - NO `--system-site-packages` flag (would break pyzmq isolation)
   - GNU Radio accessed via explicit sys.path manipulation

2. **NumPy 1.x Constraint**
   ```toml
   "numpy>=1.24,<2.0"  # NEVER upgrade to 2.x - will break GNU Radio
   ```
   - This cascades to constrain scipy, pandas, matplotlib versions
   - Build verification ensures NumPy 1.x is maintained

3. **Docker Layer Optimization**
   ```dockerfile
   # Layers 1-5: Rarely change (cached)
   # Layer 6: Dependencies from pyproject.toml (rebuilds on change)
   # Layers 7-9: Always rebuild (fast)
   ```
   Result: Dependency changes = ~2 minute rebuild, not 10+

4. **User Permission Handling**
   - Container user (jovyan) maps to host UID/GID
   - Build args passed: `USER_ID` and `GROUP_ID`
   - All mounted volumes maintain correct permissions

### Directory Structure
```
/
├── gnuradio_jupyter_docker_manager.sh  # Main management script
├── docker/
│   ├── Dockerfile                      # Multi-stage optimized build
│   ├── docker-compose.yml              # Container orchestration
│   ├── jupyter_template_system_config.py
│   ├── docker_build_verification_tests.py
│   └── templates/
│       └── gnuradio_notebook_starter_template.json
├── config/
│   └── pyproject.toml                  # Dependencies & notebook config
├── notebooks/                           # Your notebooks (persistent)
├── flowgraphs/                         # GNU Radio flowgraphs
├── scripts/                            # Python scripts
└── data/                               # Data files
```

## 📦 Installation & Usage

### Build the Image
```bash
# Standard build
./gnuradio_jupyter_docker_manager.sh build

# Clean rebuild (no cache)
./gnuradio_jupyter_docker_manager.sh rebuild

# Build specific variant
./gnuradio_jupyter_docker_manager.sh build dev
```

### Container Management
```bash
# Start (finds available port automatically)
./gnuradio_jupyter_docker_manager.sh start

# Start specific variant on different port
./gnuradio_jupyter_docker_manager.sh start dev  # Uses port 8889

# Stop container
./gnuradio_jupyter_docker_manager.sh stop

# View logs
./gnuradio_jupyter_docker_manager.sh logs -f

# Open shell in container
./gnuradio_jupyter_docker_manager.sh shell

# Check status
./gnuradio_jupyter_docker_manager.sh status
```

### Verification & Testing
```bash
# Quick GNU Radio test
./gnuradio_jupyter_docker_manager.sh test

# Comprehensive verification suite
./gnuradio_jupyter_docker_manager.sh verify
```

The build includes automatic verification that tests:
- Python version compatibility
- NumPy 1.x enforcement
- GNU Radio functionality
- Jupyter installation
- Template system
- File permissions

**Build fails if any test fails** - ensuring only working images.

## 🎨 Notebook Template System

### Automatic Setup
Every new notebook automatically includes:
- GNU Radio bridge configuration
- Essential imports (numpy, matplotlib, scipy)
- Helper functions for DSP
- Project configuration
- Example GNU Radio code

### Customization via pyproject.toml
```toml
[tool.jupyter]
# Add custom imports
[tool.jupyter.imports]
signal_processing = [
    "from scipy import signal",
    "from scipy.fft import fft, fftfreq",
]

# Add configuration code
[tool.jupyter.code_cells]
code_cells = [
    """SAMPLE_RATE = 2.4e6  # Your project config"""
]
```

**No rebuild needed for template changes!** Just edit and create new notebook.

## ⚠️ Critical Constraints & Known Issues

### Must-Follow Rules

1. **NumPy Version Lock**
   ```toml
   # In config/pyproject.toml
   "numpy>=1.24,<2.0"  # NEVER change to 2.x
   ```
   GNU Radio is compiled against NumPy 1.x ABI. Using 2.x = immediate crashes.

2. **Virtual Environment Isolation**
   ```dockerfile
   # NEVER add --system-site-packages to venv creation
   RUN python3 -m venv /opt/venv  # Keep it isolated
   ```

3. **Dependency Version Constraints**
   Due to NumPy 1.x requirement:
   - `scipy>=1.10,<1.14`
   - `pandas>=2.0,<2.2`
   - `matplotlib>=3.5,<3.9`
   - `ruff<0.5.0`

### Known Limitations

1. **SSHFS Mounts Don't Work**
   - Docker Compose fails with SSHFS-mounted directories
   - Solution: Always run from local filesystem
   - Error: `mkdir /path: file exists`

2. **Port Conflicts with Running Services**
   - **Issue**: Cannot start if VM or other Jupyter instance is using ports
   - **Behavior**: Script automatically finds next available port, but may still conflict
   - **Solution**: Stop conflicting services or manually specify different port
   - Default ports: default=8888, dev=8889, test=8890
   - Manual port override: `./gnuradio_jupyter_docker_manager.sh start default 9000`

3. **Limited Testing Environment**
   - **Tested only on**: Kubuntu 24.04 LTS
   - **Not tested on**: Other Linux distributions, macOS, Windows (WSL)
   - **VM conflicts**: Issues reported when running alongside VirtualBox VMs using same ports

4. **Management Script Has Duplicate Functions**
   - The bash script has some duplicate function definitions
   - Doesn't affect functionality but should be cleaned up

## 🔧 Advanced Usage

### Working with Variants
```bash
# Development environment (port 8889)
./gnuradio_jupyter_docker_manager.sh build dev
./gnuradio_jupyter_docker_manager.sh start dev

# Test environment (port 8890)
./gnuradio_jupyter_docker_manager.sh build test
./gnuradio_jupyter_docker_manager.sh start test

# Custom port
./gnuradio_jupyter_docker_manager.sh start default 9000
```

### Adding Python Packages
Edit `config/pyproject.toml`:
```toml
dependencies = [
    "numpy>=1.24,<2.0",  # Keep this constraint!
    "your-package>=1.0",  # Add new packages here
]
```
Then rebuild:
```bash
./gnuradio_jupyter_docker_manager.sh rebuild
```

### In Notebooks
```python
# GNU Radio is automatically available
from gnuradio import gr, blocks, analog

# Install additional packages at runtime
!pip install some-package

# Or use uv (faster)
!uv pip install some-package
```

## 🐛 Troubleshooting

### Build Failures
Check which test failed:
```
✗ NumPy version (2.0.1)
  → GNU Radio requires NumPy 1.x, not 2.x
```

### GNU Radio Import Errors
Verify the bridge is active:
```bash
docker exec gnuradio-notebook /opt/venv/bin/python -c \
  "import sys; print('/usr/lib/python3/dist-packages' in sys.path)"
```

### Template Not Applied
```bash
# Check template system
./gnuradio_jupyter_docker_manager.sh template-info

# View logs
./gnuradio_jupyter_docker_manager.sh logs | grep -i template
```

### Permission Issues
The container automatically maps to your user ID:
```bash
# This is handled automatically
docker-compose build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)
```

## 📊 Performance & Resource Usage

- **Image Size**: ~3.5GB (includes GNU Radio, Jupyter, scientific stack)
- **Build Time**: 
  - First build: ~10 minutes
  - Dependency change: ~2 minutes (cached layers)
  - Template change: No rebuild needed
- **Runtime Memory**: ~1GB minimum, 4GB recommended
- **CPU**: Benefits from multiple cores for signal processing

## 🔄 Backup & Recovery

```bash
# Backup all user data
./gnuradio_jupyter_docker_manager.sh backup

# Creates timestamped archive of:
# - notebooks/
# - flowgraphs/
# - scripts/
# - data/
# - config/
```

## 📚 Understanding the Components

### Management Script
`gnuradio_jupyter_docker_manager.sh` provides:
- Intelligent port management (auto-finds available ports)
- Variant support (dev, test, production)
- Build verification
- Backup/restore functionality
- Template system management

### Docker Build Process
1. **System packages**: GNU Radio from Ubuntu 24.04
2. **Virtual environment**: Isolated Python environment
3. **Bridge setup**: IPython startup script for GNU Radio access
4. **Template system**: Automatic notebook initialization
5. **Verification**: Comprehensive test suite

### Template System
- Base template: GNU Radio setup, imports, helpers
- Project layer: Custom configuration from pyproject.toml
- Applied automatically to all new notebooks
- No rebuild needed for template changes

## 🏷️ Version Information

- **Ubuntu**: 24.04 LTS
- **GNU Radio**: 3.10.9.2
- **Python**: 3.12
- **NumPy**: 1.26.x (1.x required!)
- **JupyterLab**: 4.x
- **Docker Compose**: 3.8

## 🧪 Testing Status

**Verified Environment:**
- **Host OS**: Kubuntu 24.04 LTS
- **Docker**: 20.10+
- **Architecture**: x86_64

**Known Limitations:**
- Only tested on Kubuntu 24.04 - compatibility with other distributions not verified
- Port conflicts with VMs and existing Jupyter instances require manual resolution
- SSHFS mount directories are not supported

## 📄 License

MIT License (or your chosen license)

## 🙏 Acknowledgments

This project was developed with significant technical assistance from Claude 4.1 Opus, which helped architect the virtual environment isolation strategy, resolve complex dependency conflicts, and implement the automatic notebook template system.

