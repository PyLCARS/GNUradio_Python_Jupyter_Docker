# GNU Radio + Jupyter Docker Environment

A Docker environment that solves the infamous pyzmq conflict between GNU Radio (system packages) and Jupyter (Python packages) through venv isolation.

## Quick Start

```bash
# Build and start
./gnuradio-lab.sh build
./gnuradio-lab.sh start

# Access Jupyter
http://localhost:8888/lab?token=docker
```

## Development Workflow

Always test changes in `dev` variant first:
```bash
./gnuradio-lab.sh rebuild dev  # Force clean rebuild
./gnuradio-lab.sh start dev     # Runs on port 8889
./verify_setup.sh dev           # Check everything works
```

## Package Management

### Using requirements.txt (Simple)
Edit `requirements.txt` with your packages:
```txt
numpy>=1.24,<2.0  # MUST stay below 2.0 for GNU Radio
scipy>=1.10,<1.14
your-package-here
```
Then rebuild: `./gnuradio-lab.sh rebuild dev`

### Using pyproject.toml (Full Project)
For complex projects, use `pyproject.toml`:
```toml
[project]
dependencies = [
    "numpy>=1.24,<2.0",  # GNU Radio constraint
    "your-package-here",
]

[project.optional-dependencies]
dev = ["ipdb", "black"]  # Install with: pip install -e .[dev]
```

### Using Both
- Docker looks for both files during build
- If both exist, both get installed
- Use `requirements.txt` for simple lists
- Use `pyproject.toml` for project metadata + optional deps
- To use only one: just don't create the other file

### Removing Files
To disable either:
```bash
rm requirements.txt     # Only use pyproject.toml
# OR
rm pyproject.toml      # Only use requirements.txt
```

## In Notebooks

```python
# GNU Radio auto-loads via IPython startup
from gnuradio import gr, blocks  # Just works!

# Install packages (no --user needed)
!pip install package-name

# Or use UV for speed
!uv pip install package-name
```

## Architecture Notes

**The Sacred Rule**: Never break venv isolation
- System Python: GNU Radio + system pyzmq
- Venv Python (`/opt/venv`): Jupyter + its own pyzmq
- Bridge: `sys.path.append('/usr/lib/python3/dist-packages')`

**NumPy Constraint**: GNU Radio needs NumPy 1.x
- All packages must be compatible with `numpy<2.0`
- Don't upgrade numpy or things break

## Commands

```bash
./gnuradio-lab.sh build [variant]   # Build image
./gnuradio-lab.sh rebuild [variant] # Clean rebuild (no cache)
./gnuradio-lab.sh start [variant]   # Start container
./gnuradio-lab.sh stop [variant]    # Stop container
./gnuradio-lab.sh shell [variant]   # Bash shell in container
./gnuradio-lab.sh logs [variant]    # View logs
./gnuradio-lab.sh clean [variant]   # Remove image & container
./gnuradio-lab.sh list              # Show all variants
```

Variants:
- `(none)` = production on port 8888
- `dev` = development on port 8889
- `test` = testing on port 8890

## Troubleshooting

**GNU Radio import fails**: Check numpy version (`!pip list | grep numpy`). Must be <2.0

**Package conflicts**: Rebuild clean (`./gnuradio-lab.sh rebuild dev`)

**Verify setup**: Run `./verify_setup.sh dev` - all checks should pass

## Files

- `Dockerfile` - The entire setup (don't break venv isolation!)
- `docker-compose.yml` - Base compose config
- `gnuradio-lab.sh` - Management script
- `requirements.txt` - Simple package list (optional)
- `pyproject.toml` - Full project config (optional)
- `verify_setup.sh` - Verification script

---
*Remember: The pyzmq isolation is sacred. The numpy<2.0 constraint is mandatory. Always rebuild for reproducibility.*
