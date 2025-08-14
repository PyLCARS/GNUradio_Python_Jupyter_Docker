# GNU Radio + Jupyter Docker Environment

A sophisticated Docker environment that combines GNU Radio (system packages) with Jupyter Lab (Python packages) through virtual environment isolation, featuring automatic notebook templates for rapid development.

## 🚀 Quick Start

```bash
# Build the Docker image
./gnuradio-lab.sh build

# Start the container
./gnuradio-lab.sh start

# Access Jupyter Lab
http://localhost:8888/lab?token=docker
```

**New notebooks automatically include GNU Radio setup!** No manual imports needed.

## 🎯 Key Features

- **GNU Radio 3.10.9.2** from Ubuntu packages (not pip/conda)
- **Jupyter Lab** in isolated virtual environment
- **Automatic notebook templates** - every new notebook starts ready
- **No pyzmq conflicts** - proper venv isolation
- **NumPy 1.x enforced** - GNU Radio compatibility maintained
- **Build verification** - tests ensure working images
- **Fast rebuilds** - intelligent layer caching

## 📋 Prerequisites

- Docker installed and running
- Linux host (tested on Ubuntu)
- ~4GB disk space for image
- Basic familiarity with Jupyter notebooks

## 🏗️ Architecture

### The Core Challenge Solved

GNU Radio from apt and Jupyter from pip have conflicting pyzmq versions. This setup uses virtual environment isolation to solve this permanently.

```
System Python (/usr/bin/python3)
├── GNU Radio (apt packages)
├── System pyzmq (required by GNU Radio)
└── Other system packages

Virtual Environment (/opt/venv)
├── Jupyter Lab
├── Different pyzmq version (for Jupyter)
├── NumPy 1.x (GNU Radio requirement)
└── All Python packages

Bridge: sys.path.append('/usr/lib/python3/dist-packages')
```

### Docker Build Layers

The Dockerfile is optimized for fast rebuilds:

| Layer | Content | Cache Behavior |
|-------|---------|----------------|
| 1-4 | System packages, venv, user setup | Cached (rarely changes) |
| 5 | Template system | Cached (rarely changes) |
| **6** | **pyproject.toml dependencies** | **Rebuilds when you edit deps** |
| 7-10 | Kernel, permissions, verification | Always rebuilds (fast) |

**Result:** Changing Python dependencies only rebuilds from layer 6 (typically <2 minutes).

## 📦 Installation

### 1. Clone or Download Files

Required files:
```
Dockerfile
docker-compose.yml
gnuradio-lab.sh          # Management script
pyproject.toml           # Dependencies & template config
jupyter_notebook_config.py
gnuradio_base_template.json
verify_build.py
```

### 2. Build the Image

```bash
# Standard build (uses cache)
./gnuradio-lab.sh build

# Clean rebuild (no cache)
./gnuradio-lab.sh rebuild

# Development variant (port 8889)
./gnuradio-lab.sh build dev
```

Build includes automatic verification - if tests fail, build fails.

### 3. Start Container

```bash
./gnuradio-lab.sh start
```

## 🎨 Template System

Every new notebook automatically includes:

### Base Template (Always Included)
- GNU Radio bridge setup
- NumPy/Matplotlib/SciPy imports
- Helper functions for DSP
- Example GNU Radio flowgraph
- Directory setup

### Project Customization (Optional)
Edit `pyproject.toml` to add:
- Project-specific imports
- Configuration variables
- Custom functions
- Documentation sections

**No rebuild needed for template content changes!**

See [README_TEMPLATES.md](README_TEMPLATES.md) for full template documentation.

## 📝 Configuration

### Python Dependencies (`pyproject.toml`)

```toml
[project]
dependencies = [
    "numpy>=1.24,<2.0",  # MUST be 1.x for GNU Radio
    "scipy>=1.10,<1.14",
    "pandas>=2.0,<2.2",
    "matplotlib>=3.5,<3.9",
    # Add your packages here
]
```

After changing dependencies:
```bash
./gnuradio-lab.sh rebuild
```

### Template Customization (`pyproject.toml`)

```toml
[tool.jupyter]
# Add custom imports (no rebuild needed!)
[tool.jupyter.imports]
my_project = [
    "import my_module",
    "from my_package import something"
]

# Add code cells
[tool.jupyter.code_cells]
code_cells = [
    "SAMPLE_RATE = 2.4e6  # Your config"
]
```

## 🔧 Usage

### Management Commands

```bash
# Core operations
./gnuradio-lab.sh build [variant]    # Build image
./gnuradio-lab.sh start [variant]    # Start container
./gnuradio-lab.sh stop [variant]     # Stop container
./gnuradio-lab.sh restart [variant]  # Restart container

# Development
./gnuradio-lab.sh shell [variant]    # Bash shell in container
./gnuradio-lab.sh logs [variant]     # View logs
./gnuradio-lab.sh test [variant]     # Test GNU Radio & templates
./gnuradio-lab.sh verify [variant]   # Run all verification tests

# Management
./gnuradio-lab.sh clean [variant]    # Remove container & image
./gnuradio-lab.sh backup             # Backup notebooks & config
./gnuradio-lab.sh status [variant]   # Show status
```

### In Notebooks

```python
# GNU Radio is automatically available (from template)
from gnuradio import gr, blocks, analog

# Install additional packages
!pip install package-name

# Or use UV (faster)
!uv pip install package-name
```

## 🧪 Verification System

Build includes comprehensive tests:

```
✓ Python version (3.12)
✓ NumPy version (1.26.4)  # Must be 1.x
✓ GNU Radio 3.10.9.2
✓ Jupyter Lab 4.4.5
✓ Template system (8 cells)
✓ Package imports
✓ File permissions
```

Run manually:
```bash
./gnuradio-lab.sh verify
```

## ⚠️ Critical Constraints

### NumPy Version
**MUST use NumPy 1.x** - GNU Radio is compiled against NumPy 1.x

```toml
# In pyproject.toml
"numpy>=1.24,<2.0"  # Never change to 2.x
```

### Virtual Environment Isolation
**NEVER use `--system-site-packages`** - This breaks pyzmq isolation

### GNU Radio Bridge
Notebooks need this to access GNU Radio:
```python
import sys
sys.path.append('/usr/lib/python3/dist-packages')
```
(Automatically included via templates)

## 🐛 Troubleshooting

### Build Fails

Check the specific test that failed:
```
✗ NumPy version (2.0.1)
  → GNU Radio requires NumPy 1.x, not 2.x
```

### Templates Not Applied

Check logs:
```bash
./gnuradio-lab.sh logs | grep -i template
```

Should see: `Successfully applied GNU Radio template`

### GNU Radio Import Errors

Verify in notebook:
```python
import sys
print('/usr/lib/python3/dist-packages' in sys.path)  # Should be True
```

### Permission Errors

The Docker build handles UID/GID mapping:
```bash
# Builds with your user ID
./gnuradio-lab.sh build
```

## 📁 Project Structure

```
project/
├── Dockerfile                    # Layer-optimized build
├── docker-compose.yml            # Container config
├── gnuradio-lab.sh              # Management script
├── pyproject.toml               # Dependencies & templates
├── jupyter_notebook_config.py   # Template system
├── gnuradio_base_template.json  # Base notebook template
├── verify_build.py              # Build tests
│
├── notebooks/                   # Your work (mounted)
├── data/                       # Data files (mounted)
├── flowgraphs/                # GNU Radio files (mounted)
└── logs/                      # Jupyter logs (mounted)
```

## 🔄 Development Workflow

1. **Edit code** in notebooks (auto-saved to host)
2. **Add packages** to pyproject.toml → rebuild
3. **Customize templates** in pyproject.toml → no rebuild
4. **Test changes** with verification script

### Variants for Development

```bash
# Production (port 8888)
./gnuradio-lab.sh start

# Development (port 8889)
./gnuradio-lab.sh start dev

# Test (port 8890)
./gnuradio-lab.sh start test
```

## 📚 Documentation

- **[README_TEMPLATES.md](README_TEMPLATES.md)** - Complete template system guide
- **[README_usage.md](README_usage.md)** - Original usage documentation
- **pyproject.toml** - Inline comments for configuration

## 🏷️ Version Information

- **Ubuntu**: 24.04 LTS
- **GNU Radio**: 3.10.9.2
- **Python**: 3.12
- **NumPy**: 1.26.x (1.x required)
- **Jupyter Lab**: 4.x
- **Template System**: v1.0.0

## 🤝 Contributing

Key files to understand:
1. `Dockerfile` - Build process
2. `jupyter_notebook_config.py` - Template manager
3. `verify_build.py` - Test suite
4. `gnuradio-lab.sh` - Management interface

## 📄 License

Your license here

## 🙏 Acknowledgments

Built to solve the notorious GNU Radio + Jupyter integration challenge while providing a professional development environment with automatic templates.

---

*For detailed template customization, see [README_TEMPLATES.md](README_TEMPLATES.md)*