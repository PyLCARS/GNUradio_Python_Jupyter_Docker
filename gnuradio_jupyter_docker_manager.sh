#!/bin/bash

# GNU Radio Jupyter Docker Management Script
# Version: 3.0.0 - Cleaned up but with ALL diagnostic features preserved
# Usage: ./gnuradio_jupyter_docker_manager.sh [command] [variant] [options]

# set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$SCRIPT_DIR"
readonly BASE_NAME="gnuradio-notebook"
readonly DEFAULT_TOKEN="docker"
readonly DEFAULT_PORT="8888"

# Paths
readonly DOCKER_DIR="${PROJECT_ROOT}/docker"
readonly CONFIG_DIR="${PROJECT_ROOT}/config"
readonly DATA_DIRS=("notebooks" "flowgraphs" "scripts" "data" "logs")

# ============================================================================
# COLORS & FORMATTING
# ============================================================================

# Only use colors if output is a terminal
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly MAGENTA='\033[0;35m'
    readonly NC='\033[0m'
    readonly BOLD='\033[1m'
else
    readonly RED='' GREEN='' YELLOW='' BLUE='' CYAN='' MAGENTA='' NC='' BOLD=''
fi

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Logging functions
log() { echo -e "$*"; }
log_info() { log "${BLUE}ℹ${NC} $*"; }
log_success() { log "${GREEN}✅${NC} $*"; }
log_warning() { log "${YELLOW}⚠️${NC}  $*"; }
log_error() { log "${RED}❌${NC} $*" >&2; }
log_step() { log "${CYAN}→${NC} $*"; }
log_debug() { [[ "${DEBUG:-0}" == "1" ]] && log "${MAGENTA}[DEBUG]${NC} $*"; }

# Print a header box
print_header() {
    local title="$1"
    local color="${2:-$BLUE}"
    log "${color}╔══════════════════════════════════════╗${NC}"
    log "${color}║$(printf "%*s%-*s" $(((40-${#title})/2)) "" $(((40-${#title})/2 + (40-${#title})%2)) "$title")║${NC}"
    log "${color}╚══════════════════════════════════════╝${NC}"
}

# Get IP address
get_ip() {

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}


# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
# Find an available port

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
find_available_port() {

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    local start_port="${1:-8888}"

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    local port=$start_port

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    while [ $port -le 9999 ]; do

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
            echo $port

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
            return 0

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
        fi

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
        ((port++))

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    done

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    log_error "No available ports found between $start_port and 9999"

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    return 1

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
}

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}


# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
# Find an available port

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
find_available_port() {

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    local start_port="${1:-8888}"

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    local port=$start_port

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    while [ $port -le 9999 ]; do

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
            echo $port

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
            return 0

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
        fi

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
        ((port++))

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    done

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    log_error "No available ports found between $start_port and 9999"

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    return 1

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
}

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
    hostname -I 2>/dev/null | awk '{print $1}' || echo "localhost"

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}
}

# Find an available port
find_available_port() {
    local start_port="${1:-8888}"
    local port=$start_port
    
    while [ $port -le 9999 ]; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
           ! docker ps --format "table {{.Ports}}" | grep -q ":$port->"; then
            echo $port
            return 0
        fi
        ((port++))
    done
    
    log_error "No available ports found between $start_port and 9999"
    return 1
}

# ============================================================================
# VARIANT CONFIGURATION
# ============================================================================

# Configure variant settings
configure_variant() {
    local variant="${1:-default}"
    local custom_port="${2:-}"
    
    # Set names based on variant
    if [[ "$variant" == "default" ]]; then
        IMAGE_NAME="${BASE_NAME}"
        CONTAINER_NAME="${BASE_NAME}"
        COMPOSE_PROJECT="${BASE_NAME}"
        PORT="${custom_port:-$DEFAULT_PORT}"
    else
        IMAGE_NAME="${BASE_NAME}-${variant}"
        CONTAINER_NAME="${BASE_NAME}-${variant}"
        COMPOSE_PROJECT="${BASE_NAME}-${variant}"
        
        # Auto-assign ports for common variants if not specified
        if [[ -z "$custom_port" ]]; then
            case "$variant" in
                dev)  PORT="8889" ;;
                test) PORT="8890" ;;
                prod) PORT="8888" ;;
                *)    PORT="8888" ;;
            esac
        else
            PORT="$custom_port"
        fi
    fi
    
    # Export for docker-compose
    export IMAGE_NAME CONTAINER_NAME COMPOSE_PROJECT HOST_PORT="$PORT"
    export VARIANT="$variant"
    export USER_ID="$(id -u)"
    export GROUP_ID="$(id -g)"
    export TOKEN="${JUPYTER_TOKEN:-$DEFAULT_TOKEN}"
    
    log_debug "Configured variant: $variant (port: $PORT)"
}

# Show variant info
show_variant_info() {
    log "${MAGENTA}╔══════════════════════════════════════╗${NC}"
    if [[ "$VARIANT" == "default" ]]; then
        log "${MAGENTA}║ Using: ${CYAN}DEFAULT${MAGENTA} configuration        ║${NC}"
    else
        log "${MAGENTA}║ Using variant: ${CYAN}${VARIANT}$(printf '%*s' $((24-${#VARIANT})) '')${MAGENTA}║${NC}"
    fi
    log "${MAGENTA}╚══════════════════════════════════════╝${NC}"
    log "  Image:     ${CYAN}${IMAGE_NAME}${NC}"
    log "  Container: ${CYAN}${CONTAINER_NAME}${NC}"
    log "  Port:      ${CYAN}${PORT}${NC}"
    echo
}

# ============================================================================
# DOCKER OPERATIONS
# ============================================================================

# Check if container is running
is_running() {
    docker ps --format "{{.Names}}" 2>/dev/null | grep -q "^${CONTAINER_NAME}$"
}

# Check if image exists
image_exists() {
    docker images --format "{{.Repository}}" 2>/dev/null | grep -q "^${IMAGE_NAME}$"
}

# Create docker-compose override
create_compose_override() {
    cat > "${DOCKER_DIR}/.docker-compose.override.yml" << EOF
# Auto-generated override for variant: ${VARIANT}
services:
  jupyter:
    image: ${IMAGE_NAME}
    container_name: ${CONTAINER_NAME}
    ports:
      - "${PORT}:8888"
    volumes:
      - ${PROJECT_ROOT}/notebooks:/home/jovyan/notebooks
      - ${PROJECT_ROOT}/flowgraphs:/home/jovyan/flowgraphs
      - ${PROJECT_ROOT}/scripts:/home/jovyan/scripts
      - ${PROJECT_ROOT}/data:/home/jovyan/data
      - ${CONFIG_DIR}/pyproject.toml:/home/jovyan/pyproject.toml:ro
EOF
}

# Clean up override file
cleanup_override() {
    rm -f "${DOCKER_DIR}/.docker-compose.override.yml"
}

# Run docker-compose with proper setup
docker_compose() {
    local action="$1"
    shift
    
    cd "$DOCKER_DIR"
    create_compose_override
    
    docker-compose \
        -p "${COMPOSE_PROJECT}" \
        -f docker-compose.yml \
        -f .docker-compose.override.yml \
        "$action" "$@"
    
    local result=$?
    cleanup_override
    return $result
}

# ============================================================================
# FILE SYSTEM OPERATIONS
# ============================================================================

# Check required files
check_required_files() {
    local missing=()
    local files=(
        "${DOCKER_DIR}/Dockerfile"
        "${CONFIG_DIR}/pyproject.toml"
        "${DOCKER_DIR}/jupyter_template_system_config.py"
        "${DOCKER_DIR}/templates/gnuradio_notebook_starter_template.json"
        "${DOCKER_DIR}/docker_build_verification_tests.py"
    )
    
    for file in "${files[@]}"; do
        [[ ! -f "$file" ]] && missing+=("${file#$PROJECT_ROOT/}")
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required files:"
        for file in "${missing[@]}"; do
            log "  ${RED}• $file${NC}"
        done
        return 1
    fi
    return 0
}

# Create project directories
create_directories() {
    for dir in "${DATA_DIRS[@]}"; do
        local path="${PROJECT_ROOT}/${dir}"
        if [[ ! -d "$path" ]]; then
            mkdir -p "$path"
            touch "$path/.gitkeep"
            log_debug "Created directory: $dir"
        fi
    done
}

# ============================================================================
# BUILD COMMANDS
# ============================================================================

cmd_build() {
    local no_cache=""
    local build_type="standard"
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --no-cache) no_cache="--no-cache"; build_type="clean" ;;
            --dev) export BUILD_TARGET="development" ;;
            --prod) export BUILD_TARGET="production" ;;
        esac
        shift
    done
    
    show_variant_info
    check_required_files || return 1
    
    log_info "Starting ${BOLD}${build_type}${NC} build..."
    log_step "Building with UID: ${USER_ID}, GID: ${GROUP_ID}"
    
    # Show pyproject.toml hash for cache tracking
    if [[ -f "${CONFIG_DIR}/pyproject.toml" ]]; then
        local hash=$(md5sum "${CONFIG_DIR}/pyproject.toml" | cut -d' ' -f1)
        log_step "pyproject.toml hash: ${CYAN}${hash:0:8}${NC}"
    fi
    
    create_directories
    
    # Build with Docker
    cd "$PROJECT_ROOT"
    
    log_info "Building Docker image..."
    if docker build \
        $no_cache \
        --tag "${IMAGE_NAME}" \
        --build-arg USER_ID="${USER_ID}" \
        --build-arg GROUP_ID="${GROUP_ID}" \
        --build-arg BUILD_TARGET="${BUILD_TARGET:-production}" \
        -f "${DOCKER_DIR}/Dockerfile" \
        . ; then
        
        log_success "Build completed successfully"
        log_success "All verification tests passed"
        
        # Show image details
        log_info "Image details:"
        docker images "${IMAGE_NAME}" --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}"
    else
        log_error "Build failed - check output above"
        return 1
    fi
}

cmd_rebuild() {
    log_warning "Rebuilding from scratch (no cache)..."
    cmd_build --no-cache
}

# ============================================================================
# CONTAINER LIFECYCLE
# ============================================================================

cmd_start() {
    show_variant_info
    
    if ! image_exists; then
        log_warning "Image not found: ${CYAN}${IMAGE_NAME}${NC}"
        log_info "Building image first..."
        cmd_build || return 1
    fi
    
    if is_running; then
        log_warning "Container already running: ${CYAN}${CONTAINER_NAME}${NC}"
        return 0
    fi
    
    # Check for port availability BEFORE trying to start
    ORIGINAL_PORT=$PORT
    while lsof -i :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 || docker ps --format "table {{.Ports}}" | grep -q ":$PORT->"; do
        log_warning "Port $PORT is in use, trying next port..."
        ((PORT++))
        if [ $PORT -gt 9000 ]; then
            log_error "No available ports found between $ORIGINAL_PORT and 9000"
            log_info "Try: docker ps -a | grep 8888  # to see what is using the port"
            return 1
        fi
    done
    
    if [ "$PORT" != "$ORIGINAL_PORT" ]; then
        log_success "Found available port: $PORT"
        export HOST_PORT=$PORT
    fi
    
    log_info "Starting GNU Radio Notebook on port $PORT..."
    create_directories
    
    docker_compose up -d
    
    # Wait for startup
    log_step "Waiting for Jupyter to start..."
    local attempts=0
    while [[ $attempts -lt 10 ]]; do
        if docker exec "${CONTAINER_NAME}" /opt/venv/bin/jupyter lab list &>/dev/null; then
            break
        fi
        sleep 1
        ((attempts++))
    done
    
    if is_running; then
        local ip=$(get_ip)
        
        echo
        print_header "GNU Radio Notebook Running!" "$GREEN"
        echo
        log "${YELLOW}Access URLs:${NC}"
        log "  Local:   ${CYAN}http://localhost:${PORT}/lab?token=${TOKEN}${NC}"
        log "  Network: ${CYAN}http://${ip}:${PORT}/lab?token=${TOKEN}${NC}"
        echo
        log "${YELLOW}Token: ${CYAN}${TOKEN}${NC}"
        [[ "$VARIANT" != "default" ]] && log "${YELLOW}Variant: ${CYAN}${VARIANT}${NC}"
        echo
        log "${BLUE}Directories:${NC}"
        log "  📓 Notebooks: ${CYAN}./notebooks/${NC}"
        log "  📊 Data:      ${CYAN}./data/${NC}"
        log "  📡 Flowgraphs: ${CYAN}./flowgraphs/${NC}"
        log "  🐍 Scripts:   ${CYAN}./scripts/${NC}"
    else
        log_error "Failed to start - check logs:"
        docker logs "${CONTAINER_NAME}" --tail=20
        return 1
    fi
}

cmd_stop() {
    show_variant_info
    
    if ! is_running; then
        log_info "Container not running: ${CYAN}${CONTAINER_NAME}${NC}"
        return 0
    fi
    
    log_info "Stopping GNU Radio Notebook..."
    docker_compose down
    log_success "Container stopped"
}

cmd_restart() {
    cmd_stop && sleep 2 && cmd_start
}

# ============================================================================
# DIAGNOSTIC COMMANDS (ALL PRESERVED FROM ORIGINAL)
# ============================================================================

cmd_status() {
    show_variant_info
    print_header "System Status" "$BLUE"
    
    if is_running; then
        log "${GREEN}✅ Container RUNNING${NC}"
        echo
        log "${YELLOW}Access:${NC}"
        log "  ${CYAN}http://localhost:${PORT}/lab?token=${TOKEN}${NC}"
        echo
        docker stats --no-stream "${CONTAINER_NAME}" 2>/dev/null || true
    else
        log "${YELLOW}○ Container STOPPED${NC}"
        if image_exists; then
            log "${GREEN}✅ Image exists${NC}"
            log "  Run '${CYAN}$SCRIPT_NAME start $VARIANT${NC}' to launch"
        else
            log "${RED}❌ Image not found${NC}"
            log "  Run '${CYAN}$SCRIPT_NAME build $VARIANT${NC}' to build"
        fi
    fi
}

cmd_logs() {
    local follow=""
    [[ "${1:-}" == "-f" || "${1:-}" == "--follow" ]] && follow="-f"
    
    show_variant_info
    log_info "Showing logs (Ctrl+C to exit)..."
    docker logs $follow "${CONTAINER_NAME}" 2>/dev/null || log_error "No logs available"
}

cmd_shell() {
    show_variant_info
    
    if ! is_running; then
        log_error "Container not running"
        log_info "Start with: ${CYAN}$SCRIPT_NAME start $VARIANT${NC}"
        return 1
    fi
    
    log_info "Opening shell (type 'exit' to return)..."
    docker exec -it "${CONTAINER_NAME}" bash
}

cmd_test() {
    show_variant_info
    
    if ! is_running; then
        log_error "Container not running"
        return 1
    fi
    
    log_info "Running GNU Radio tests..."
    
    docker exec "${CONTAINER_NAME}" python3 -c "
import sys
sys.path.append('/usr/lib/python3/dist-packages')
from gnuradio import gr
print(f'✅ GNU Radio {gr.version()} is working!')

# Test template system
import json
from pathlib import Path
template_path = Path('/home/jovyan/.jupyter/templates/gnuradio_notebook_starter_template.json')
if template_path.exists():
    with open(template_path) as f:
        template = json.load(f)
    print(f'✅ Template system configured with {len(template.get(\"cells\", []))} cells')
else:
    print('❌ Template system not found')

# Test NumPy version
import numpy as np
major_version = int(np.__version__.split('.')[0])
if major_version == 1:
    print(f'✅ NumPy {np.__version__} (GNU Radio compatible)')
else:
    print(f'❌ NumPy {np.__version__} - GNU Radio requires 1.x!')
"
}

cmd_verify() {
    show_variant_info
    
    if ! is_running; then
        log_error "Container not running"
        return 1
    fi
    
    log_info "Running comprehensive verification..."
    
    # Copy verify script to container if not present
    if [[ -f "${DOCKER_DIR}/docker_build_verification_tests.py" ]]; then
        docker cp "${DOCKER_DIR}/docker_build_verification_tests.py" "${CONTAINER_NAME}:/tmp/docker_build_verification_tests.py"
    fi
    
    docker exec "${CONTAINER_NAME}" /opt/venv/bin/python /tmp/docker_build_verification_tests.py
}

# ============================================================================
# DATA MANAGEMENT COMMANDS (ALL PRESERVED)
# ============================================================================

cmd_backup() {
    local backup_name="gnuradio_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    log_info "Creating backup..."
    log_step "Including notebooks, data, configs..."
    
    cd "$PROJECT_ROOT"
    
    tar -czf "$backup_name" \
        --exclude='*.pyc' \
        --exclude='__pycache__' \
        --exclude='.ipynb_checkpoints' \
        notebooks/ \
        flowgraphs/ \
        scripts/ \
        data/ \
        docker/ \
        config/ \
        "$0" \
        2>/dev/null || true
    
    log_success "Backup saved as: ${CYAN}${backup_name}${NC}"
    log_info "Size: $(du -h "$backup_name" | cut -f1)"
}

cmd_export() {
    show_variant_info
    
    if ! image_exists; then
        log_error "Image not found: ${CYAN}${IMAGE_NAME}${NC}"
        return 1
    fi
    
    local export_name="${IMAGE_NAME}-$(date +%Y%m%d-%H%M%S).tar.gz"
    log_info "Exporting image to ${CYAN}${export_name}${NC}..."
    
    docker save "${IMAGE_NAME}" | gzip > "$export_name"
    
    log_success "Export complete!"
    log_info "Size: $(du -h "$export_name" | cut -f1)"
    log_info "Import with: ${CYAN}docker load < $export_name${NC}"
}

cmd_import() {
    local file="${1:-}"
    
    if [[ -z "$file" ]]; then
        log_error "Please specify file to import"
        log_info "Usage: $SCRIPT_NAME import <file.tar.gz>"
        return 1
    fi
    
    if [[ ! -f "$file" ]]; then
        log_error "File not found: ${CYAN}${file}${NC}"
        return 1
    fi
    
    log_info "Importing image from ${CYAN}${file}${NC}..."
    
    if gunzip -c "$file" | docker load; then
        log_success "Import complete!"
        docker images | grep "${BASE_NAME}"
    else
        log_error "Import failed"
        return 1
    fi
}

# ============================================================================
# TEMPLATE SYSTEM COMMANDS (PRESERVED)
# ============================================================================

cmd_template_info() {
    show_variant_info
    print_header "Template System Information" "$YELLOW"
    
    echo
    log "${YELLOW}Template Files:${NC}"
    log "  ${CYAN}gnuradio_notebook_starter_template.json${NC} - Base template"
    log "  ${CYAN}pyproject.toml${NC} - Project customization"
    echo
    log "${YELLOW}How it works:${NC}"
    log "  1. Base template is baked into Docker image"
    log "  2. Project settings from pyproject.toml overlay"
    log "  3. Every new notebook gets both applied"
    echo
    
    # Check template files
    local template_path="${DOCKER_DIR}/templates/gnuradio_notebook_starter_template.json"
    local pyproject_path="${CONFIG_DIR}/pyproject.toml"
    
    if [[ -f "$template_path" ]]; then
        log "${GREEN}✅ Base template found${NC}"
        local cells=$(python3 -c "import json; print(len(json.load(open('$template_path'))['cells']))" 2>/dev/null || echo "?")
        log "   ${cells} template cells configured"
    else
        log "${RED}❌ Base template missing${NC}"
    fi
    
    if [[ -f "$pyproject_path" ]]; then
        log "${GREEN}✅ pyproject.toml found${NC}"
        if grep -q "\[tool.jupyter\]" "$pyproject_path"; then
            log "${GREEN}✅ Jupyter configuration detected${NC}"
        else
            log "${YELLOW}⚠️  No [tool.jupyter] section${NC}"
        fi
    else
        log "${RED}❌ pyproject.toml missing${NC}"
    fi
}

# ============================================================================
# CLEANUP COMMANDS (PRESERVED)
# ============================================================================

cmd_clean() {
    show_variant_info
    
    log "${YELLOW}This will remove:${NC}"
    log "  • Container: ${CYAN}${CONTAINER_NAME}${NC}"
    log "  • Image: ${CYAN}${IMAGE_NAME}${NC}"
    log "${GREEN}Your notebooks and data will be preserved${NC}"
    echo
    
    read -p "Continue? (y/N) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        is_running && docker stop "${CONTAINER_NAME}" 2>/dev/null
        docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true
        docker rmi "${IMAGE_NAME}" 2>/dev/null || true
        log_success "Cleanup complete"
    else
        log_info "Cancelled"
    fi
}

# ============================================================================
# LIST/INFO COMMANDS (PRESERVED)
# ============================================================================

cmd_list() {
    print_header "GNU Radio Notebook Variants" "$BLUE"
    
    echo
    log "${YELLOW}Images:${NC}"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep "${BASE_NAME}" || log "  None found"
    
    echo
    log "${YELLOW}Containers:${NC}"
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep "${BASE_NAME}" || log "  None found"
}

# ============================================================================
# HELP SYSTEM
# ============================================================================

cmd_help() {
    print_header "GNU Radio Jupyter Docker Manager" "$GREEN"
    
    cat << EOF

${BOLD}Usage:${NC} $SCRIPT_NAME COMMAND [VARIANT] [OPTIONS]

${BOLD}Core Commands:${NC}
  ${CYAN}start${NC} [variant] [port]  Start notebook container
  ${CYAN}stop${NC} [variant]          Stop notebook container
  ${CYAN}restart${NC} [variant]       Restart container
  ${CYAN}status${NC} [variant]        Show container status
  ${CYAN}logs${NC} [variant] [-f]     Show container logs
  ${CYAN}shell${NC} [variant]         Open bash shell in container

${BOLD}Build Commands:${NC}
  ${CYAN}build${NC} [variant]         Build Docker image
  ${CYAN}rebuild${NC} [variant]       Rebuild without cache
  ${CYAN}verify${NC} [variant]        Run verification tests
  ${CYAN}test${NC} [variant]          Quick GNU Radio test

${BOLD}Data Management:${NC}
  ${CYAN}backup${NC}                  Backup all project files
  ${CYAN}export${NC} [variant]        Export image to tar.gz
  ${CYAN}import${NC} <file>           Import image from tar.gz

${BOLD}Information:${NC}
  ${CYAN}list${NC}                    List all variants
  ${CYAN}template-info${NC}           Show template system info

${BOLD}Cleanup:${NC}
  ${CYAN}clean${NC} [variant]         Remove container and image

${BOLD}Variants:${NC}
  ${GREEN}default${NC}   Production version (port 8888)
  ${GREEN}dev${NC}       Development version (port 8889)
  ${GREEN}test${NC}      Test version (port 8890)
  ${GREEN}<custom>${NC}  Any custom name

${BOLD}Examples:${NC}
  $SCRIPT_NAME start                # Start default
  $SCRIPT_NAME start dev            # Start development
  $SCRIPT_NAME build --dev          # Build with dev target
  $SCRIPT_NAME start test 9000      # Custom port
  $SCRIPT_NAME logs -f              # Follow logs
  $SCRIPT_NAME verify dev           # Run full verification

${BOLD}Build Options:${NC}
  --no-cache    Rebuild without Docker cache
  --dev         Build development version
  --prod        Build production version

${BOLD}Environment Variables:${NC}
  JUPYTER_TOKEN    Custom token (default: docker)
  DEBUG           Enable debug output (DEBUG=1)

EOF
}

# ============================================================================
# MAIN ENTRY POINT
# ============================================================================

main() {
    # Check Docker availability
    if ! command -v docker &>/dev/null; then
        log_error "Docker is not installed"
        log_info "Please install Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! docker info &>/dev/null; then
        log_error "Docker daemon is not running"
        log_info "Please start Docker and try again"
        exit 1
    fi
    
    # Parse command
    local cmd="${1:-help}"
    shift || true
    
    # Handle help flags at any position
    for arg in "$@"; do
        [[ "$arg" == "--help" || "$arg" == "-h" ]] && cmd="help"
    done
    
    # Parse variant (could be second arg or after options)
    local variant="default"
    local args=()
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --*)
                args+=("$1")
                ;;
            -*)
                args+=("$1")
                ;;
            *)
                if [[ "$variant" == "default" && "$1" != "" ]]; then
                    variant="$1"
                else
                    args+=("$1")
                fi
                ;;
        esac
        shift
    done
    
    # Configure variant
    configure_variant "$variant" "${args[0]:-}"
    
    # Execute command
    case "$cmd" in
        # Core commands
        start|up)       cmd_start ;;
        stop|down)      cmd_stop ;;
        restart)        cmd_restart ;;
        status|ps)      cmd_status ;;
        logs|log)       cmd_logs "${args[@]}" ;;
        shell|sh|bash)  cmd_shell ;;
        
        # Build commands
        build)          cmd_build "${args[@]}" ;;
        rebuild)        cmd_rebuild ;;
        test)           cmd_test ;;
        verify)         cmd_verify ;;
        
        # Data management
        backup)         cmd_backup ;;
        export)         cmd_export ;;
        import)         cmd_import "${args[@]}" ;;
        
        # Information
        list|ls)        cmd_list ;;
        template-info)  cmd_template_info ;;
        
        # Cleanup
        clean|rm)       cmd_clean ;;
        
        # Help
        help|--help|-h) cmd_help ;;
        
        # Unknown
        *)
            log_error "Unknown command: ${cmd}"
            log_info "Run '${CYAN}$SCRIPT_NAME help${NC}' for usage"
            exit 1
            ;;
    esac
}

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

# Trap to ensure cleanup on exit
trap cleanup_override EXIT

# Run main function with all arguments
main "$@"
