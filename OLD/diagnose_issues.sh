#!/bin/bash

# Diagnose GNU Radio initialization and pip --user issues

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

VARIANT=${1:-dev}
CONTAINER="gnuradio-jupyter-${VARIANT}"

echo -e "${CYAN}=== Diagnosing Issues in $CONTAINER ===${NC}"
echo ""

# 1. Check GNU Radio in detail
echo -e "${YELLOW}1. GNU Radio Detailed Check:${NC}"
docker exec $CONTAINER /opt/venv/bin/python -c "
import sys
sys.path.append('/usr/lib/python3/dist-packages')
print('sys.path includes:')
for p in sys.path:
    if 'dist-packages' in p:
        print(f'  {p}')

print('\nTrying to import GNU Radio components:')
try:
    import numpy
    print(f'  ✓ numpy {numpy.__version__}')
except ImportError as e:
    print(f'  ✗ numpy: {e}')

try:
    from gnuradio import gr
    print(f'  ✓ GNU Radio gr module loaded')
    print(f'  ✓ Version: {gr.version()}')
except ImportError as e:
    print(f'  ✗ GNU Radio gr: {e}')
except Exception as e:
    print(f'  ✗ GNU Radio initialization error: {e}')

try:
    from gnuradio import blocks
    print(f'  ✓ GNU Radio blocks module loaded')
except ImportError as e:
    print(f'  ✗ GNU Radio blocks: {e}')
except Exception as e:
    print(f'  ✗ GNU Radio blocks error: {e}')
"

# 2. Check if GNU Radio files exist
echo -e "\n${YELLOW}2. GNU Radio Files Check:${NC}"
echo "Checking /usr/lib/python3/dist-packages/gnuradio:"
docker exec $CONTAINER ls -la /usr/lib/python3/dist-packages/ | grep gnuradio || echo "  No gnuradio directory found!"
docker exec $CONTAINER ls -la /usr/lib/python3/dist-packages/gnuradio/ 2>/dev/null | head -10 || echo "  Cannot list gnuradio contents"

# 3. Check numpy versions (GNU Radio might need specific numpy)
echo -e "\n${YELLOW}3. Numpy Version Conflicts:${NC}"
docker exec $CONTAINER /opt/venv/bin/python -c "
import sys
print('Venv numpy:')
try:
    import numpy
    print(f'  Version: {numpy.__version__}')
    print(f'  Location: {numpy.__file__}')
except ImportError:
    print('  Not installed in venv')

sys.path.insert(0, '/usr/lib/python3/dist-packages')
import importlib
import numpy as np_system
print('\nSystem numpy:')
print(f'  Version: {np_system.__version__}')
print(f'  Location: {np_system.__file__}')
"

# 4. Check pip --user issue
echo -e "\n${YELLOW}4. pip install --user Diagnosis:${NC}"
docker exec $CONTAINER /opt/venv/bin/python -c "
import os
import site
import sys

print(f'Python: {sys.executable}')
print(f'PYTHONUSERBASE: {os.environ.get(\"PYTHONUSERBASE\")}')
print(f'site.USER_BASE: {site.USER_BASE}')
print(f'site.USER_SITE: {site.USER_SITE}')
print(f'User site enabled: {site.ENABLE_USER_SITE}')

# Check if .local directory exists and is writable
import pathlib
local_dir = pathlib.Path('/home/jovyan/.local')
print(f'\n.local directory exists: {local_dir.exists()}')
if local_dir.exists():
    print(f'.local directory writable: {os.access(str(local_dir), os.W_OK)}')
"

# 5. Try pip install --user with verbose output
echo -e "\n${YELLOW}5. Verbose pip install --user test:${NC}"
docker exec $CONTAINER /opt/venv/bin/python -m pip install --user --verbose requests 2>&1 | head -20

# 6. Check LD_LIBRARY_PATH for GNU Radio
echo -e "\n${YELLOW}6. Library paths for GNU Radio:${NC}"
docker exec $CONTAINER bash -c "
echo 'LD_LIBRARY_PATH: '\$LD_LIBRARY_PATH
echo ''
echo 'GNU Radio libraries:'
ls -la /usr/lib/x86_64-linux-gnu/ | grep gnuradio | head -5
"

# 7. Test GNU Radio with system Python directly
echo -e "\n${YELLOW}7. GNU Radio with system Python (baseline test):${NC}"
docker exec $CONTAINER /usr/bin/python3 -c "
try:
    from gnuradio import gr
    print(f'✓ System Python can load GNU Radio {gr.version()}')
except Exception as e:
    print(f'✗ Even system Python fails: {e}')
"

echo -e "\n${CYAN}=== Diagnosis Complete ===${NC}"
