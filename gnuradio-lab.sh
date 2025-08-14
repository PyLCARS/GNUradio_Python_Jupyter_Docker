#!/bin/bash

# GNU Radio Lab Management Script with Template System Support
# Version: 2.0.0 - With Notebook Templates
# Usage: ./gnuradio-lab.sh [command] [variant]

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
BASE_NAME="gnuradio-jupyter"
TOKEN="docker"

# Get command and variant
COMMAND=$1
VARIANT=$2

# Determine image and container names based on variant
if [ -z "$VARIANT" ]; then
    IMAGE_NAME="${BASE_NAME}"
    CONTAINER_NAME="${BASE_NAME}"
    COMPOSE_PROJECT="${BASE_NAME}"
    PORT="8888"
else
    IMAGE_NAME="${BASE_NAME}-${VARIANT}"
    CONTAINER_NAME="${BASE_NAME}-${VARIANT}"
    COMPOSE_PROJECT="${BASE_NAME}-${VARIANT}"
    # Use different ports for different variants to avoid conflicts
    case "$VARIANT" in
        dev)
            PORT="8889"
            ;;
        test)
            PORT="8890"
            ;;
        *)
            PORT="8888"
            ;;
    esac
fi

# Export for docker-compose
export IMAGE_NAME
export CONTAINER_NAME
export HOST_PORT=$PORT
export VARIANT=${VARIANT:-default}

# Get IP
IP=$(hostname -I | awk '{print $1}')

# Create docker-compose override for this variant
create_compose_override() {
    cat > .docker-compose.override.yml << EOF
# Temporary override file for variant: ${VARIANT:-default}
# This file is auto-generated and should not be committed
services:
  jupyter:
    image: ${IMAGE_NAME}
    container_name: ${CONTAINER_NAME}
    ports:
      - "${PORT}:8888"
EOF
}

# Helper function to check if container is running
is_running() {
    docker ps --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"
}

# Helper function to check if image exists
image_exists() {
    docker images --format "{{.Repository}}" | grep -q "^${IMAGE_NAME}$"
}

# Show current variant info
show_variant_info() {
    echo -e "${MAGENTA}╔══════════════════════════════════════╗${NC}"
    if [ -z "$VARIANT" ]; then
        echo -e "${MAGENTA}║ Using: ${CYAN}DEFAULT${MAGENTA} configuration        ║${NC}"
    else
        echo -e "${MAGENTA}║ Using variant: ${CYAN}${VARIANT}$(printf '%*s' $((24-${#VARIANT})) '')${MAGENTA}║${NC}"
    fi
    echo -e "${MAGENTA}╚══════════════════════════════════════╝${NC}"
    echo -e "  Image:     ${CYAN}${IMAGE_NAME}${NC}"
    echo -e "  Container: ${CYAN}${CONTAINER_NAME}${NC}"
    echo -e "  Port:      ${CYAN}${PORT}${NC}"
    echo ""
}

# Check for required files
check_required_files() {
    local missing_files=()
    
    # Check for required build files
    [ ! -f "Dockerfile" ] && missing_files+=("Dockerfile")
    [ ! -f "pyproject.toml" ] && missing_files+=("pyproject.toml")
    [ ! -f "jupyter_notebook_config.py" ] && missing_files+=("jupyter_notebook_config.py")
    [ ! -f "gnuradio_base_template.json" ] && missing_files+=("gnuradio_base_template.json")
    [ ! -f "verify_build.py" ] && missing_files+=("verify_build.py")
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        echo -e "${RED}❌ Missing required files:${NC}"
        for file in "${missing_files[@]}"; do
            echo -e "  ${RED}• $file${NC}"
        done
        echo -e "${YELLOW}Please ensure all required files are present.${NC}"
        return 1
    fi
    return 0
}

case "$COMMAND" in
    rebuild)
        show_variant_info
        
        # Check required files
        if ! check_required_files; then
            exit 1
        fi
        
        echo -e "${CYAN}🔨 Rebuilding GNU Radio Lab image from scratch...${NC}"
        echo -e "${YELLOW}This will ignore all cached layers${NC}"

        # Get current user's UID and GID for the build
        USER_ID=$(id -u)
        GROUP_ID=$(id -g)
        echo -e "${YELLOW}Building with UID: ${USER_ID}, GID: ${GROUP_ID}${NC}"

        # Create directories
        mkdir -p notebooks flowgraphs scripts data

        # Show pyproject.toml hash for cache tracking
        if [ -f pyproject.toml ]; then
            PYPROJECT_HASH=$(md5sum pyproject.toml | cut -d' ' -f1)
            echo -e "${YELLOW}pyproject.toml hash: ${CYAN}${PYPROJECT_HASH:0:8}${NC}"
        fi

        echo -e "${YELLOW}Removing any existing image to ensure fresh build...${NC}"
        docker rmi ${IMAGE_NAME} 2>/dev/null || true

        # Build with no cache
        echo -e "${BLUE}Building with verification tests...${NC}"
        docker build \
            --no-cache \
            --pull \
            --tag ${IMAGE_NAME} \
            --build-arg USER_ID=${USER_ID} \
            --build-arg GROUP_ID=${GROUP_ID} \
            -f Dockerfile \
            .

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Image rebuilt successfully: ${CYAN}${IMAGE_NAME}${NC}"
            echo -e "${GREEN}✅ All verification tests passed${NC}"
            echo -e "${GREEN}   UID/GID: ${USER_ID}/${GROUP_ID}${NC}"
            
            # Show image details
            echo -e "${YELLOW}Image details:${NC}"
            docker images ${IMAGE_NAME} --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}"
        else
            echo -e "${RED}❌ Rebuild failed - check verification output above${NC}"
            exit 1
        fi
        ;;

    build)
        show_variant_info
        
        # Check required files
        if ! check_required_files; then
            exit 1
        fi
        
        echo -e "${CYAN}🔨 Building GNU Radio Lab image...${NC}"
        
        # Get current user's UID and GID for the build
        USER_ID=$(id -u)
        GROUP_ID=$(id -g)
        echo -e "${YELLOW}Building with UID: ${USER_ID}, GID: ${GROUP_ID}${NC}"
        
        # Show layer cache status
        echo -e "${YELLOW}Layer cache status:${NC}"
        if [ -f pyproject.toml ]; then
            PYPROJECT_HASH=$(md5sum pyproject.toml | cut -d' ' -f1)
            echo -e "  pyproject.toml hash: ${CYAN}${PYPROJECT_HASH:0:8}${NC}"
            echo -e "  ${BLUE}Changes to pyproject.toml will rebuild from layer 6${NC}"
        fi

        # Create directories
        mkdir -p notebooks flowgraphs scripts data

        # Build with Docker
        echo -e "${BLUE}Building with verification tests...${NC}"
        docker build \
            --tag ${IMAGE_NAME} \
            --build-arg USER_ID=${USER_ID} \
            --build-arg GROUP_ID=${GROUP_ID} \
            -f Dockerfile \
            .

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Build completed successfully${NC}"
            echo -e "${GREEN}✅ All verification tests passed${NC}"
            echo -e "${GREEN}   UID/GID: ${USER_ID}/${GROUP_ID}${NC}"
        else
            echo -e "${RED}❌ Build failed verification${NC}"
            echo -e "${RED}Check the test output above for details${NC}"
            exit 1
        fi
        ;;

    start|up)
        show_variant_info

        # Check if image exists
        if ! image_exists; then
            echo -e "${YELLOW}⚠️  Image ${CYAN}${IMAGE_NAME}${YELLOW} not found!${NC}"
            echo -e "${YELLOW}   Run: ${CYAN}$0 build ${VARIANT}${NC}"
            exit 1
        fi

        echo -e "${CYAN}🚀 Starting GNU Radio Lab...${NC}"

        # Create directories if needed
        mkdir -p notebooks flowgraphs scripts data logs

        # Create the override file
        create_compose_override

        # Set user/group IDs for runtime
        export USER_ID=$(id -u)
        export GROUP_ID=$(id -g)

        # Start container with specific project name
        docker-compose -p ${COMPOSE_PROJECT} -f docker-compose.yml -f .docker-compose.override.yml up -d

        # Clean up override
        rm -f .docker-compose.override.yml

        # Wait for startup
        echo -e "${YELLOW}⏳ Waiting for Jupyter to start...${NC}"
        sleep 5

        # Check if running
        if is_running; then
            echo ""
            echo -e "${GREEN}✅ GNU Radio Jupyter Lab is running!${NC}"
            echo ""
            echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
            echo -e "${BLUE}║ ${GREEN}📡 GNU Radio ${CYAN}3.10.9.2${GREEN} + Jupyter Lab ${BLUE}║${NC}"
            echo -e "${BLUE}║ ${YELLOW}📝 Template System Active${BLUE}            ║${NC}"
            echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
            echo ""
            echo -e "${YELLOW}Access from this machine:${NC}"
            echo -e "  ${CYAN}http://localhost:${PORT}/lab?token=${TOKEN}${NC}"
            echo -e "  ${CYAN}http://127.0.0.1:${PORT}/lab?token=${TOKEN}${NC}"
            echo ""
            echo -e "${YELLOW}Access from network:${NC}"
            echo -e "  ${CYAN}http://${IP}:${PORT}/lab?token=${TOKEN}${NC}"
            echo ""
            echo -e "${GREEN}Token: ${CYAN}${TOKEN}${NC}"
            if [ ! -z "$VARIANT" ]; then
                echo -e "${MAGENTA}Variant: ${CYAN}${VARIANT}${NC}"
            fi
            echo ""
            echo -e "${BLUE}Template Info:${NC}"
            echo -e "  ${YELLOW}• Base template loaded from Docker${NC}"
            echo -e "  ${YELLOW}• Project config from pyproject.toml${NC}"
            echo -e "  ${YELLOW}• New notebooks will use templates${NC}"
            echo ""
            echo -e "${BLUE}══════════════════════════════════════${NC}"
            echo ""
            echo -e "${YELLOW}📚 Notebooks saved in: ${CYAN}./notebooks/${NC}"
            echo -e "${YELLOW}📊 Data files in: ${CYAN}./data/${NC}"
            echo -e "${YELLOW}📝 Logs in: ${CYAN}./logs/${NC}"
        else
            echo -e "${RED}❌ Failed to start. Check logs:${NC}"
            docker logs ${CONTAINER_NAME} --tail=50
        fi
        ;;

    stop|down)
        show_variant_info
        echo -e "${YELLOW}🛑 Stopping GNU Radio Lab...${NC}"

        # Create the override file
        create_compose_override

        docker-compose -p ${COMPOSE_PROJECT} -f docker-compose.yml -f .docker-compose.override.yml down

        # Clean up override
        rm -f .docker-compose.override.yml

        echo -e "${GREEN}✅ Stopped${NC}"
        ;;

    restart)
        $0 stop $VARIANT
        sleep 2
        $0 start $VARIANT
        ;;

    logs)
        show_variant_info
        echo -e "${YELLOW}📋 Showing logs (Ctrl+C to exit)...${NC}"
        docker logs -f ${CONTAINER_NAME}
        ;;

    clean)
        show_variant_info
        echo -e "${RED}🧹 Cleaning Docker environment...${NC}"
        echo -e "${YELLOW}This will remove:${NC}"
        echo -e "  - Container: ${CYAN}${CONTAINER_NAME}${NC}"
        echo -e "  - Image: ${CYAN}${IMAGE_NAME}${NC}"
        echo -e "${YELLOW}Your notebooks and data will be preserved.${NC}"
        read -p "Continue? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker stop ${CONTAINER_NAME} 2>/dev/null || true
            docker rm ${CONTAINER_NAME} 2>/dev/null || true
            docker rmi ${IMAGE_NAME} 2>/dev/null || true
            echo -e "${GREEN}✅ Cleaned${NC}"
        else
            echo -e "${YELLOW}Cancelled${NC}"
        fi
        ;;

    status)
        show_variant_info
        echo -e "${BLUE}══════════════════════════════════════${NC}"
        if is_running; then
            echo -e "${GREEN}✅ GNU Radio Lab is RUNNING${NC}"
            echo -e "${BLUE}══════════════════════════════════════${NC}"
            echo ""
            echo -e "${YELLOW}Local access:${NC}"
            echo -e "  ${CYAN}http://localhost:${PORT}/lab?token=${TOKEN}${NC}"
            echo ""
            echo -e "${YELLOW}Network access:${NC}"
            echo -e "  ${CYAN}http://${IP}:${PORT}/lab?token=${TOKEN}${NC}"
            echo ""
            echo -e "${YELLOW}Template System:${NC}"
            echo -e "  ${GREEN}✅ Active - new notebooks will use templates${NC}"
            echo ""
            # Show container stats
            docker stats --no-stream ${CONTAINER_NAME}
        else
            echo -e "${RED}▪ GNU Radio Lab is STOPPED${NC}"
            echo -e "${BLUE}══════════════════════════════════════${NC}"
            if image_exists; then
                echo -e "${GREEN}Image exists: ${CYAN}${IMAGE_NAME}${NC}"
                echo -e "${YELLOW}Run '$0 start ${VARIANT}' to launch${NC}"
            else
                echo -e "${RED}Image not found: ${CYAN}${IMAGE_NAME}${NC}"
                echo -e "${YELLOW}Run '$0 build ${VARIANT}' to build${NC}"
            fi
        fi
        ;;

    shell|bash)
        show_variant_info
        if is_running; then
            echo -e "${YELLOW}🖥️  Opening shell in container...${NC}"
            echo -e "${CYAN}Type 'exit' to return${NC}"
            docker exec -it ${CONTAINER_NAME} bash
        else
            echo -e "${RED}Container is not running. Start it first with '$0 start ${VARIANT}'${NC}"
        fi
        ;;

    test)
        show_variant_info
        if is_running; then
            echo -e "${YELLOW}🧪 Running GNU Radio test...${NC}"
            docker exec ${CONTAINER_NAME} python3 -c "
import sys
sys.path.append('/usr/lib/python3/dist-packages')
from gnuradio import gr
print(f'✅ GNU Radio {gr.version()} is working!')

# Test template system
import json
from pathlib import Path
template_path = Path('/home/jovyan/.jupyter/templates/gnuradio_base_template.json')
if template_path.exists():
    with open(template_path) as f:
        template = json.load(f)
    print(f'✅ Template system configured with {len(template.get(\"cells\", []))} cells')
else:
    print('❌ Template system not found')
"
        else
            echo -e "${RED}Container is not running. Start it first with '$0 start ${VARIANT}'${NC}"
        fi
        ;;

    verify)
        show_variant_info
        if is_running; then
            echo -e "${YELLOW}🔍 Running comprehensive verification...${NC}"
            docker exec ${CONTAINER_NAME} /opt/venv/bin/python -c "
import subprocess
result = subprocess.run(['/opt/venv/bin/python', '/tmp/verify_build.py'], 
                       capture_output=True, text=True)
print(result.stdout)
if result.returncode != 0:
    print(result.stderr)
    exit(1)
"
        else
            echo -e "${RED}Container is not running. Start it first with '$0 start ${VARIANT}'${NC}"
        fi
        ;;

    list)
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║     ${GREEN}GNU Radio Lab Variants${BLUE}          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Images:${NC}"
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep "${BASE_NAME}" || echo "  None found"
        echo ""
        echo -e "${YELLOW}Containers:${NC}"
        docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep "${BASE_NAME}" || echo "  None found"
        ;;

    export)
        show_variant_info
        if image_exists; then
            EXPORT_NAME="${IMAGE_NAME}-$(date +%Y%m%d-%H%M%S).tar.gz"
            echo -e "${YELLOW}📦 Exporting image to ${CYAN}${EXPORT_NAME}${NC}..."
            docker save ${IMAGE_NAME} | gzip > ${EXPORT_NAME}
            echo -e "${GREEN}✅ Exported successfully!${NC}"
            echo -e "   Size: $(du -h ${EXPORT_NAME} | cut -f1)"
        else
            echo -e "${RED}Image not found: ${CYAN}${IMAGE_NAME}${NC}"
            echo -e "${YELLOW}Build it first with: $0 build ${VARIANT}${NC}"
        fi
        ;;

    import)
        if [ -z "$VARIANT" ]; then
            echo -e "${RED}Please specify the tar.gz file to import${NC}"
            echo -e "Usage: $0 import <file.tar.gz>"
            exit 1
        fi
        if [ -f "$VARIANT" ]; then
            echo -e "${YELLOW}📦 Importing image from ${CYAN}${VARIANT}${NC}..."
            docker load < $VARIANT
            echo -e "${GREEN}✅ Import complete!${NC}"
        else
            echo -e "${RED}File not found: ${CYAN}${VARIANT}${NC}"
        fi
        ;;

    backup)
        BACKUP_NAME="gnuradio_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
        echo -e "${YELLOW}💾 Creating backup...${NC}"
        echo -e "${BLUE}Including template files and configuration...${NC}"
        tar -czf ${BACKUP_NAME} \
            notebooks/ \
            flowgraphs/ \
            scripts/ \
            data/ \
            Dockerfile \
            docker-compose.yml \
            pyproject.toml \
            jupyter_notebook_config.py \
            gnuradio_base_template.json \
            verify_build.py \
            $0 \
            2>/dev/null
        echo -e "${GREEN}✅ Backup saved as: ${CYAN}${BACKUP_NAME}${NC}"
        ;;

    template-info)
        show_variant_info
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║     ${YELLOW}Template System Information${BLUE}      ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Template Files:${NC}"
        echo -e "  ${CYAN}gnuradio_base_template.json${NC} - Base template (Docker)"
        echo -e "  ${CYAN}pyproject.toml${NC} - Project customization"
        echo ""
        echo -e "${YELLOW}How it works:${NC}"
        echo -e "  1. Base template is baked into Docker image"
        echo -e "  2. Project settings from pyproject.toml layer on top"
        echo -e "  3. Every new notebook gets both templates applied"
        echo ""
        echo -e "${YELLOW}Customization:${NC}"
        echo -e "  Edit ${CYAN}pyproject.toml${NC} [tool.jupyter] section"
        echo -e "  Changes apply to new notebooks immediately"
        echo -e "  No rebuild needed for template changes"
        echo ""
        if [ -f pyproject.toml ]; then
            echo -e "${GREEN}✅ pyproject.toml found${NC}"
            grep -q "\[tool.jupyter\]" pyproject.toml && \
                echo -e "${GREEN}✅ Template configuration detected${NC}" || \
                echo -e "${YELLOW}⚠️  No [tool.jupyter] section found${NC}"
        else
            echo -e "${RED}❌ pyproject.toml not found${NC}"
        fi
        ;;

    help|--help|-h|*)
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║  ${GREEN}GNU Radio Lab Management Script${BLUE}     ║${NC}"
        echo -e "${BLUE}║  ${YELLOW}Version 2.0 - With Templates${BLUE}        ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        echo ""
        echo "Usage: $0 {command} [variant]"
        echo ""
        echo "Variants:"
        echo -e "  ${CYAN}(none)${NC}   - Use default/production image"
        echo -e "  ${CYAN}dev${NC}      - Development version (port 8889)"
        echo -e "  ${CYAN}test${NC}     - Test version (port 8890)"
        echo -e "  ${CYAN}<name>${NC}   - Any custom name (port 8888)"
        echo ""
        echo "Commands:"
        echo -e "  ${CYAN}build [variant]${NC}     - Build image with caching"
        echo -e "  ${CYAN}rebuild [variant]${NC}   - Rebuild from scratch (no cache)"
        echo -e "  ${CYAN}start [variant]${NC}     - Start container"
        echo -e "  ${CYAN}stop [variant]${NC}      - Stop container"
        echo -e "  ${CYAN}restart [variant]${NC}   - Restart container"
        echo -e "  ${CYAN}status [variant]${NC}    - Show status"
        echo -e "  ${CYAN}logs [variant]${NC}      - Show live logs"
        echo -e "  ${CYAN}shell [variant]${NC}     - Open bash shell"
        echo -e "  ${CYAN}test [variant]${NC}      - Test GNU Radio & templates"
        echo -e "  ${CYAN}verify [variant]${NC}    - Run verification tests"
        echo -e "  ${CYAN}clean [variant]${NC}     - Remove container and image"
        echo -e "  ${CYAN}list${NC}                - List all variants"
        echo -e "  ${CYAN}export [variant]${NC}    - Export image to tar.gz"
        echo -e "  ${CYAN}import <file>${NC}       - Import image from tar.gz"
        echo -e "  ${CYAN}backup${NC}              - Backup all files and data"
        echo -e "  ${CYAN}template-info${NC}       - Show template system info"
        echo -e "  ${CYAN}help${NC}                - Show this help"
        echo ""
        echo -e "${BLUE}══════════════════════════════════════${NC}"
        echo "Examples:"
        echo -e "  ${GREEN}$0 build dev${NC}        # Build development version"
        echo -e "  ${GREEN}$0 start dev${NC}        # Start development version"
        echo -e "  ${GREEN}$0 template-info${NC}    # Check template setup"
        echo -e "  ${GREEN}$0 verify dev${NC}       # Verify the build"
        echo ""

        # Show current status
        echo -e "${BLUE}══════════════════════════════════════${NC}"
        echo -e "${YELLOW}Available variants:${NC}"
        docker images --format "  {{.Repository}}" | grep "^${BASE_NAME}" | sed "s/^${BASE_NAME}$/  ${BASE_NAME} (default)/" | sed "s/^${BASE_NAME}-/  /" || echo "  None built yet"
        
        # Check for template files
        echo ""
        echo -e "${YELLOW}Template files status:${NC}"
        [ -f "gnuradio_base_template.json" ] && echo -e "  ${GREEN}✅ Base template${NC}" || echo -e "  ${RED}❌ Base template missing${NC}"
        [ -f "jupyter_notebook_config.py" ] && echo -e "  ${GREEN}✅ Jupyter config${NC}" || echo -e "  ${RED}❌ Jupyter config missing${NC}"
        [ -f "pyproject.toml" ] && echo -e "  ${GREEN}✅ Project config${NC}" || echo -e "  ${RED}❌ Project config missing${NC}"
        [ -f "verify_build.py" ] && echo -e "  ${GREEN}✅ Verification script${NC}" || echo -e "  ${RED}❌ Verification script missing${NC}"
        ;;
esac

# Clean up any leftover override files
[ -f .docker-compose.override.yml ] && rm -f .docker-compose.override.yml
