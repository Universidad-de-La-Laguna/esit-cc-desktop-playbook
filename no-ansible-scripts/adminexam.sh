#!/bin/bash
# Script purpose: Setup adminexam user for teacher or student machines

# === CONFIGURATION ===
SCRIPT_NAME="$(basename "$0")"
LOG_DIR="/var/log"
LOG_FILE="${LOG_DIR}/${SCRIPT_NAME%.*}.log"
HOSTNAME=$(hostname)
MODE=""
SSH_KEY_FILE=""
ADMIN_PASSWORD=""

# === COLORS ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# === ERROR HANDLING ===
set -o pipefail

error_exit() {
    local line=$1
    local command=$2
    local exit_code=$3
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') | Host: ${HOSTNAME} | Line: ${line} | Command: ${command} | Exit Code: ${exit_code}" | tee -a "${LOG_FILE}"
    exit ${exit_code}
}

trap 'error_exit ${LINENO} "${BASH_COMMAND}" $?' ERR

# === LOGGING ===
log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') | $1" | tee -a "${LOG_FILE}"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') | $1" | tee -a "${LOG_FILE}"
}

# === HELP FUNCTION ===
show_help() {
    cat << EOF
Usage: ${SCRIPT_NAME} --mode <teacher|student> [OPTIONS]

Description:
    Configures adminexam user for teacher or student machines.
    
    Teacher mode:
      - Creates adminexam user with password
      - Generates SSH key pair
      - Exports public key to id_adminexam.pub
    
    Student mode:
      - Creates adminexam user
      - Enables passwordless sudo
      - Configures SSH key authentication

Options:
    -h, --help              Show this help message
    -m, --mode              Mode: teacher or student (required)
    -p, --password          Password for adminexam user (teacher mode only, optional)
    -k, --ssh-key-file      Path to SSH public key file (student mode only, required)

Examples:
    # Teacher machine
    ${SCRIPT_NAME} --mode teacher
    ${SCRIPT_NAME} --mode teacher --password MiPassword123
    
    # Student machine
    ${SCRIPT_NAME} --mode student --ssh-key-file id_adminexam.pub
    
EOF
    exit 0
}

# === PARAMETER PARSING ===
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -p|--password)
            ADMIN_PASSWORD="$2"
            shift 2
            ;;
        -k|--ssh-key-file)
            SSH_KEY_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

# === VALIDATION ===
if [[ -z "${MODE}" ]]; then
    echo -e "${RED}Error: --mode is required${NC}"
    show_help
fi

if [[ "${MODE}" != "teacher" && "${MODE}" != "student" ]]; then
    echo -e "${RED}Error: --mode must be 'teacher' or 'student'${NC}"
    show_help
fi

if [[ "${MODE}" == "student" && -z "${SSH_KEY_FILE}" ]]; then
    echo -e "${RED}Error: --ssh-key-file is required for student mode${NC}"
    show_help
fi

if [[ "${MODE}" == "student" && ! -f "${SSH_KEY_FILE}" ]]; then
    echo -e "${RED}Error: SSH key file '${SSH_KEY_FILE}' not found${NC}"
    exit 1
fi

# === TEACHER MODE ===
setup_teacher() {
    log_info "Starting teacher machine setup on ${HOSTNAME}"
    
    log_info "Creating group adminexam"
    groupadd -f adminexam
    
    log_info "Creating user adminexam"
    useradd -m -s /bin/bash -g adminexam adminexam 2>/dev/null || log_warn "User adminexam already exists"
    
    if [[ -z "${ADMIN_PASSWORD}" ]]; then
        log_info "Setting password for adminexam user (interactive)"
        passwd adminexam
    else
        log_info "Setting password for adminexam user"
        echo "adminexam:${ADMIN_PASSWORD}" | chpasswd
    fi
    
    log_info "Generating SSH key pair for adminexam user"
    su - adminexam -c "ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N '' -C 'adminexam@teacher-machine'"
    
    log_info "Copying public key to current directory"
    cp /home/adminexam/.ssh/id_rsa.pub ./id_adminexam.pub
    chmod 644 ./id_adminexam.pub
    
    log_info "Setup completed successfully on ${HOSTNAME}"
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}TEACHER MACHINE CONFIGURED${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Public key exported to: ./id_adminexam.pub${NC}"
    echo -e "${GREEN}Copy this file to student machines${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# === STUDENT MODE ===
setup_student() {
    log_info "Starting student machine setup on ${HOSTNAME}"
    
    log_info "Updating package cache"
    apt update
    
    log_info "Creating group adminexam"
    groupadd -f adminexam
    
    log_info "Configuring passwordless sudo for adminexam group"
    cat > /etc/sudoers.d/adminexam << 'SUDOEOF'
%adminexam ALL=(ALL) NOPASSWD: ALL
SUDOEOF
    chmod 440 /etc/sudoers.d/adminexam
    
    log_info "Creating user adminexam"
    useradd -m -s /bin/bash -g adminexam adminexam 2>/dev/null || log_warn "User adminexam already exists"
    usermod -a -G adminexam adminexam
    
    log_info "Setting up SSH authorized keys"
    mkdir -p /home/adminexam/.ssh
    cat "${SSH_KEY_FILE}" > /home/adminexam/.ssh/authorized_keys
    chown -R adminexam:adminexam /home/adminexam/.ssh
    chmod 700 /home/adminexam/.ssh
    chmod 600 /home/adminexam/.ssh/authorized_keys
    
    log_info "Setup completed successfully on ${HOSTNAME}"
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}STUDENT MACHINE CONFIGURED${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Teacher can now SSH without password:${NC}"
    echo -e "${GREEN}  ssh adminexam@${HOSTNAME}${NC}"
    echo -e "${GREEN}adminexam can run sudo without password${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# === MAIN EXECUTION ===
main() {
    if [[ "${MODE}" == "teacher" ]]; then
        setup_teacher
    elif [[ "${MODE}" == "student" ]]; then
        setup_student
    fi
}

main
