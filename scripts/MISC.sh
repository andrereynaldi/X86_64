#!/bin/bash

. ./scripts/INCLUDE.sh

# Initialize environment
init_environment() {
    log "INFO" "Start Downloading Misc files and setup configuration!"
    log "INFO" "Current Path: $PWD"
}

# Setup base-specific configurations
setup_base_config() {
    # Update date in init settings
    sed -i "s/Ouc3kNF6/${DATE}/g" files/etc/uci-defaults/99-init-settings.sh
    
    case "${BASE}" in
        "openwrt")
            log "INFO" "Configuring OpenWrt specific settings"
            ;;
        "immortalwrt")
            log "INFO" "Configuring ImmortalWrt specific settings"
            ;;
        *)
            log "INFO" "Unknown base system: ${BASE}}"
            ;;
    esac
}

# Setup branch-specific configurations
setup_branch_config() {
    local branch_major=$(echo "${BRANCH}" | cut -d'.' -f1)
    case "$branch_major" in
        "24")
            log "INFO" "Configuring for branch 24.x"
            ;;
        "23")
            log "INFO" "Configuring for branch 23.x"
            ;;
        *)
            log "INFO" "Unknown branch version: ${BRANCH}"
            ;;
    esac
}

# Download custom scripts
download_custom_scripts() {
    log "INFO" "Downloading custom scripts"
    
    local scripts=(
        "https://raw.githubusercontent.com/FUjr/QModem/refs/heads/main/application/qmodem/Makefile"
        "https://raw.githubusercontent.com/andrereynaldi/X86_64/refs/heads/main/misc/TTL.sh"
        "https://raw.githubusercontent.com/andrereynaldi/openwrt-packages/refs/heads/main/atc-fib-fm350_gl/Makefile"
    )
    
    for script in "${scripts[@]}"; do
        IFS='|' read -r url path <<< "$script"
        wget --no-check-certificate -nv -P "$path" "$url" || error "Failed to download: $url"
    done
}

# Main execution
main() {
    init_environment
    setup_base_config
    setup_branch_config
    download_custom_scripts
    log "SUCCESS" "All custom configuration setup completed!"
}

# Execute main function
main
