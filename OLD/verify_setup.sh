#!/bin/bash

# Verification script for GNU Radio + Jupyter setup
# Usage: ./verify_setup.sh [variant]
# Example: ./verify_setup.sh dev

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get variant (default to no variant)
VARIANT=$1
BASE_NAME="gnuradio-jupyter"

# Determine container name based on variant
if [ -z "$VARIANT" ]; then
    CONTAINER_NAME="${BASE_NAME}"
    echo -e "${CYAN}Verifying DEFAULT build${NC}"
else
    CONTAINER_NAME="${BASE_NAME}-${VARIANT}"
    echo -e "${CYAN}Verifying ${VARIANT} build${NC}"
fi

echo "Container: $CONTAINER_NAME"
echo "====================================="

# Check if container is running
if ! docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${RED}✗ Container not running${NC}"
    echo -e "${YELLOW}Start it with: ./gnuradio-lab.sh start ${VARIANT}${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Container is running${NC}"

echo -e "\n${YELLOW}1. Checking Python environments...${NC}"

# Check venv Python
echo -n "Venv Python: "
docker exec $CONTAINER_NAME /opt/venv/bin/python --version
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Venv Python exists${NC}"
else
    echo -e "${RED}✗ Venv Python missing${NC}"
fi

# Check kernel registration
echo -e "\n${YELLOW}2. Checking Jupyter kernel...${NC}"
docker exec $CONTAINER_NAME /opt/venv/bin/jupyter kernelspec list 2>/dev/null
if docker exec $CONTAINER_NAME /opt/venv/bin/jupyter kernelspec list 2>/dev/null | grep -q "python3"; then
    echo -e "${GREEN}✓ Kernel registered${NC}"
else
    echo -e "${RED}✗ Kernel not registered${NC}"
fi

# Check UV installation
echo -e "\n${YELLOW}3. Checking UV...${NC}"
docker exec $CONTAINER_NAME /opt/venv/bin/uv --version 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ UV installed${NC}"
else
    echo -e "${RED}✗ UV not found${NC}"
fi

# Check GNU Radio bridge
echo -e "\n${YELLOW}4. Testing GNU Radio bridge...${NC}"
docker exec $CONTAINER_NAME /opt/venv/bin/python -c "
import sys
sys.path.append('/usr/lib/python3/dist-packages')
try:
    from gnuradio import gr
    print(f'✓ GNU Radio {gr.version()} accessible')
    exit(0)
except ImportError as e:
    print(f'✗ GNU Radio not accessible: {e}')
    exit(1)
" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ GNU Radio bridge works${NC}"
else
    echo -e "${RED}✗ GNU Radio bridge failed${NC}"
fi

# Check environment variables
echo -e "\n${YELLOW}5. Checking environment variables...${NC}"
docker exec $CONTAINER_NAME /opt/venv/bin/python -c "
import os
userbase = os.environ.get('PYTHONUSERBASE')
if userbase == '/home/jovyan/.local':
    print(f'✓ PYTHONUSERBASE correct: {userbase}')
else:
    print(f'✗ PYTHONUSERBASE wrong: {userbase}')
" 2>/dev/null

# Check IPython startup script
echo -e "\n${YELLOW}6. Checking IPython startup script...${NC}"
if docker exec $CONTAINER_NAME test -f /home/jovyan/.ipython/profile_default/startup/00-gnuradio-bridge.py 2>/dev/null; then
    echo -e "${GREEN}✓ IPython startup script exists${NC}"
else
    echo -e "${RED}✗ IPython startup script missing${NC}"
fi

# Test pip install capability
echo -e "\n${YELLOW}7. Testing pip install --user...${NC}"
docker exec $CONTAINER_NAME /opt/venv/bin/python -m pip install --user --quiet requests 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ pip install --user works${NC}"
    # Clean up test install
    docker exec $CONTAINER_NAME /opt/venv/bin/python -m pip uninstall -y --quiet requests 2>/dev/null
else
    echo -e "${RED}✗ pip install --user failed${NC}"
fi

# Check venv isolation
echo -e "\n${YELLOW}8. Verifying venv isolation (critical!)...${NC}"
docker exec $CONTAINER_NAME /opt/venv/bin/python -c "
import sys
# Check if system packages are in default path (they shouldn't be)
dist_packages = [p for p in sys.path if 'dist-packages' in p and '/usr/lib' in p]
if not dist_packages:
    print('✓ Venv properly isolated from system packages')
    exit(0)
else:
    print(f'✗ Venv contaminated with system paths: {dist_packages}')
    exit(1)
" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ pyzmq isolation maintained${NC}"
else
    echo -e "${RED}✗ WARNING: Venv isolation broken!${NC}"
fi

# Summary
echo -e "\n${YELLOW}====================================${NC}"
echo -e "${GREEN}Verification complete for ${CYAN}${CONTAINER_NAME}${GREEN}!${NC}"
echo ""

# Determine port based on variant
if [ -z "$VARIANT" ]; then
    PORT="8888"
elif [ "$VARIANT" = "dev" ]; then
    PORT="8889"
elif [ "$VARIANT" = "test" ]; then
    PORT="8890"
else
    PORT="8888"
fi

echo "Next steps:"
echo "1. Open Jupyter at http://localhost:${PORT}/lab?token=docker"
echo "2. Create a new notebook"
echo "3. GNU Radio should auto-import (no sys.path needed)"
echo "4. Try: !pip install --user some-package"