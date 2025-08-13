#!/bin/bash

# GNU Radio Lab Management Script with Image Versioning
# Usage: ./gnuradio-lab.sh [command] [image-variant]
# Example: ./gnuradio-lab.sh build dev
#          ./gnuradio-lab.sh start dev
#          ./gnuradio-lab.sh start (uses default)

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
    echo -e "${MAGENTA}╔════════════════════════════════════════╗${NC}"
    if [ -z "$VARIANT" ]; then
        echo -e "${MAGENTA}║ Using: ${CYAN}DEFAULT${MAGENTA} configuration        ║${NC}"
    else
        echo -e "${MAGENTA}║ Using variant: ${CYAN}${VARIANT}$(printf '%*s' $((24-${#VARIANT})) '')${MAGENTA}║${NC}"
    fi
    echo -e "${MAGENTA}╚════════════════════════════════════════╝${NC}"
    echo -e "  Image:     ${CYAN}${IMAGE_NAME}${NC}"
    echo -e "  Container: ${CYAN}${CONTAINER_NAME}${NC}"
    echo -e "  Port:      ${CYAN}${PORT}${NC}"
    echo ""
}

case "$COMMAND" in
    build)
        show_variant_info
        echo -e "${CYAN}🔨 Building GNU Radio Lab image...${NC}"
        
        # Create directories
        mkdir -p notebooks flowgraphs scripts data
        
        # Create the override file
        create_compose_override
        
        # Build with specific image name
        docker-compose -p ${COMPOSE_PROJECT} -f docker-compose.yml -f .docker-compose.override.yml build
        
        # Clean up override
        rm -f .docker-compose.override.yml
        
        if image_exists; then
            echo -e "${GREEN}✅ Image built successfully: ${CYAN}${IMAGE_NAME}${NC}"
        else
            echo -e "${RED}❌ Build failed${NC}"
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
        mkdir -p notebooks flowgraphs scripts data
        
        # Create the override file
        create_compose_override
        
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
            echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
            echo -e "${BLUE}║ ${GREEN}📡 GNU Radio ${CYAN}3.10.9.2${GREEN} + Jupyter Lab ${BLUE}║${NC}"
            echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
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
            echo -e "${BLUE}════════════════════════════════════════${NC}"
            echo ""
            echo -e "${YELLOW}📝 Notebooks saved in: ${CYAN}./notebooks/${NC}"
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
        echo -e "${YELLOW}Your notebooks will be preserved.${NC}"
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
        echo -e "${BLUE}════════════════════════════════════════${NC}"
        if is_running; then
            echo -e "${GREEN}✅ GNU Radio Lab is RUNNING${NC}"
            echo -e "${BLUE}════════════════════════════════════════${NC}"
            echo ""
            echo -e "${YELLOW}Local access:${NC}"
            echo -e "  ${CYAN}http://localhost:${PORT}/lab?token=${TOKEN}${NC}"
            echo ""
            echo -e "${YELLOW}Network access:${NC}"
            echo -e "  ${CYAN}http://${IP}:${PORT}/lab?token=${TOKEN}${NC}"
            echo ""
            # Show container stats
            docker stats --no-stream ${CONTAINER_NAME}
        else
            echo -e "${RED}○ GNU Radio Lab is STOPPED${NC}"
            echo -e "${BLUE}════════════════════════════════════════${NC}"
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
        
    list)
        echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║     ${GREEN}GNU Radio Lab Variants${BLUE}             ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
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
        
    help|--help|-h|*)
        echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║  ${GREEN}GNU Radio Lab Management Script${BLUE}       ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
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
        echo -e "  ${CYAN}build [variant]${NC}  - Build image"
        echo -e "  ${CYAN}start [variant]${NC}  - Start container"
        echo -e "  ${CYAN}stop [variant]${NC}   - Stop container"
        echo -e "  ${CYAN}restart [variant]${NC}- Restart container"
        echo -e "  ${CYAN}status [variant]${NC} - Show status"
        echo -e "  ${CYAN}logs [variant]${NC}   - Show live logs"
        echo -e "  ${CYAN}shell [variant]${NC}  - Open bash shell"
        echo -e "  ${CYAN}clean [variant]${NC}  - Remove container and image"
        echo -e "  ${CYAN}list${NC}             - List all variants"
        echo -e "  ${CYAN}export [variant]${NC} - Export image to tar.gz"
        echo -e "  ${CYAN}import <file>${NC}    - Import image from tar.gz"
        echo -e "  ${CYAN}help${NC}             - Show this help"
        echo ""
        echo -e "${BLUE}════════════════════════════════════════${NC}"
        echo "Examples:"
        echo -e "  ${GREEN}$0 build dev${NC}     # Build development version"
        echo -e "  ${GREEN}$0 start dev${NC}     # Start development version"
        echo -e "  ${GREEN}$0 start${NC}         # Start default version"
        echo -e "  ${GREEN}$0 list${NC}          # See all versions"
        echo ""
        
        # Show current status
        echo -e "${BLUE}════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Available variants:${NC}"
        docker images --format "  {{.Repository}}" | grep "^${BASE_NAME}" | sed "s/^${BASE_NAME}$/  ${BASE_NAME} (default)/" | sed "s/^${BASE_NAME}-/  /" || echo "  None built yet"
        ;;
esac

# Clean up any leftover override files
[ -f .docker-compose.override.yml ] && rm -f .docker-compose.override.yml