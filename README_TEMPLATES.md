# GNU Radio Jupyter Template System

## Overview

This Docker environment now includes an automatic notebook template system that ensures every new Jupyter notebook created in the container starts with the proper GNU Radio setup and project-specific configuration.

## Architecture

The template system uses a **layered approach**:

1. **Base Layer** (Baked into Docker image)
   - GNU Radio bridge setup
   - Standard imports
   - Verification code
   - Helper functions
   
2. **Project Layer** (From `pyproject.toml`)
   - Loguru logging configuration
   - Project-specific imports
   - Custom code cells
   - Additional markdown documentation

## Quick Start

### 1. Build the Image

```bash
# First time build
./gnuradio-lab.sh build

# Or rebuild from scratch if updating
./gnuradio-lab.sh rebuild
```

### 2. Start the Container

```bash
./gnuradio-lab.sh start
```

### 3. Create a New Notebook

When you create a new notebook in Jupyter Lab, it will automatically include:
- GNU Radio bridge setup
- All configured imports
- Project-specific code
- Helper functions

## File Structure

```
project/
├── Dockerfile                      # Layered build with verification
├── docker-compose.yml             # Container configuration
├── gnuradio-lab.sh               # Management script
├── pyproject.toml                # Project config + template settings
├── jupyter_notebook_config.py    # Template manager
├── gnuradio_base_template.json  # Base notebook template
├── verify_build.py              # Build verification tests
│
├── notebooks/                   # Your notebooks (mounted)
├── data/                       # Data files (mounted)
├── flowgraphs/                # GNU Radio flowgraphs (mounted)
├── scripts/                   # Python scripts (mounted)
└── logs/                      # Log files (mounted)
```

## Customizing Templates

### Edit `pyproject.toml`

The `[tool.jupyter]` section controls what gets added to notebooks:

```toml
[tool.jupyter]
# Enable features
use_loguru = true

# Configure loguru
[tool.jupyter.loguru_config]
level = "DEBUG"
format = "{time:HH:mm:ss} | {level} | {message}"
rotation = "100 MB"

# Add imports
[tool.jupyter.imports]
signal_processing = [
    "from scipy import signal",
    "from scipy.fft import fft, fftfreq",
]

# Add markdown sections
[tool.jupyter.notebook_sections]
notebook_sections = [
    """## My Project Section
    
    Custom documentation here..."""
]

# Add code cells
[tool.jupyter.code_cells]
code_cells = [
    """# Project configuration
PROJECT_NAME = 'My_SDR_Project'
SAMPLE_RATE = 2.4e6"""
]
```

### Changes Apply Immediately

- **No rebuild needed** for template changes
- Edit `pyproject.toml`
- Create a new notebook - changes are applied
- Existing notebooks are not affected

## Build Layers

The Dockerfile is optimized for fast rebuilds:

| Layer | Content | Rebuild Frequency |
|-------|---------|------------------|
| 1-4 | System, Python, User setup | Rare |
| 5 | Template system | Rare |
| **6** | **pyproject.toml dependencies** | **When deps change** |
| 7 | Verification tests | Always |
| 8-9 | Final setup | Always |

When you change `pyproject.toml`:
- Only layers 6-9 rebuild (fast)
- Layers 1-5 use cache (instant)

## Verification System

The build includes comprehensive tests:

```bash
# During build (automatic)
- Python version check
- NumPy 1.x verification (GNU Radio requirement)
- GNU Radio functionality test
- Jupyter installation check
- Template system validation
- Package import tests
- Permission verification

# Manual verification
./gnuradio-lab.sh test    # Quick test
./gnuradio-lab.sh verify  # Full verification
```

Build **fails** if any test fails - ensuring working images only.

## Template Components

### Base Template (Always Included)

1. **Header Markdown**
   - Environment explanation
   - Important constraints
   - Architecture overview

2. **GNU Radio Bridge**
   ```python
   sys.path.append('/usr/lib/python3/dist-packages')
   from gnuradio import gr, blocks, analog
   ```

3. **Standard Imports**
   ```python
   import numpy as np  # Version 1.x enforced
   import matplotlib.pyplot as plt
   from pathlib import Path
   ```

4. **Helper Functions**
   - `create_flowgraph()`
   - `plot_complex_signal()`
   - `compute_psd()`

### Project Additions (From pyproject.toml)

These are added **after** the base template:
- Loguru logging setup
- Project-specific imports
- Configuration variables
- Custom helper functions
- Documentation sections

## Common Operations

### Check Template Status

```bash
./gnuradio-lab.sh template-info
```

### View Template in Container

```bash
# Open shell
./gnuradio-lab.sh shell

# View base template
cat ~/.jupyter/templates/gnuradio_base_template.json

# Check config
cat ~/.jupyter/jupyter_notebook_config.py
```

### Test Template System

```bash
./gnuradio-lab.sh test
```

## Troubleshooting

### Templates Not Applied?

1. Check if template files exist:
   ```bash
   ./gnuradio-lab.sh template-info
   ```

2. Verify in container:
   ```bash
   ./gnuradio-lab.sh shell
   ls -la ~/.jupyter/templates/
   ```

3. Check logs:
   ```bash
   ./gnuradio-lab.sh logs | grep -i template
   ```

### Build Fails Verification?

The build output shows exactly which test failed:
```
✗ NumPy version (2.0.1)
  → GNU Radio requires NumPy 1.x, not 2.x
```

Fix the issue and rebuild.

### Changes to pyproject.toml Not Appearing?

1. Template changes apply to **new** notebooks only
2. Existing notebooks are not modified
3. Create a new notebook to see changes

## Advanced Usage

### Multiple Projects

Use variants for different projects:

```bash
# Project A
./gnuradio-lab.sh build project-a
./gnuradio-lab.sh start project-a  # Port 8888

# Project B  
./gnuradio-lab.sh build project-b
./gnuradio-lab.sh start project-b  # Port 8888 (if A stopped)
```

### Development Workflow

```bash
# 1. Edit pyproject.toml dependencies
nano pyproject.toml

# 2. Rebuild (uses cache for layers 1-5)
./gnuradio-lab.sh build dev

# 3. Verify
./gnuradio-lab.sh verify dev

# 4. Start
./gnuradio-lab.sh start dev
```

### Export/Import Images

```bash
# Export verified image
./gnuradio-lab.sh export dev

# Import on another machine
./gnuradio-lab.sh import gnuradio-jupyter-dev-20241231-120000.tar.gz
```

## Best Practices

1. **Always verify** after building:
   ```bash
   ./gnuradio-lab.sh verify
   ```

2. **Use variants** for experiments:
   ```bash
   ./gnuradio-lab.sh build test
   ```

3. **Backup regularly**:
   ```bash
   ./gnuradio-lab.sh backup
   ```

4. **Keep NumPy < 2.0** - GNU Radio requirement

5. **Document in templates** - Add project docs to pyproject.toml

## Version Information

- Template System: v1.0.0
- GNU Radio: 3.10.9.2
- NumPy: 1.x (required)
- Python: 3.12+
- Ubuntu: 24.04

## Support

For issues or questions:
1. Check this README
2. Run `./gnuradio-lab.sh help`
3. Check verification output
4. Review Docker build logs
