#!/bin/bash

# Source include file
. ./scripts/INCLUDE.sh

# Exit on error
set -e

# Display Profile
make info

# Validasi
PROFILE=""
PACKAGES=""
MISC=""
EXCLUDED=""

# Base Openwrt Firmware Selector
PACKAGES+=" base-files ca-bundle dnsmasq dropbear e2fsprogs firewall4 \
fstools grub2-bios-setup kmod-button-hotplug kmod-nft-offload libc \
libgcc libustream-mbedtls logd mkf2fs mtd netifd nftables odhcp6c \
odhcpd-ipv6only opkg partx-utils ppp ppp-mod-pppoe procd-ujail uci \
uclient-fetch urandom-seed urngd kmod-e1000e kmod-e1000 \
kmod-fs-vfat kmod-igb kmod-r8169 kmod-drm-i915 luci"

# Core system + Web Server + LuCI
PACKAGES+=" bash block-mount coreutils-base64 coreutils-sleep coreutils-stat \
coreutils-stty curl wget-ssl tar unzip parted losetup uhttpd uhttpd-mod-ubus \
luci-base luci-mod-admin-full luci-lib-ip luci-compat luci-ssl"

# USB to LAN
PACKAGES+=" kmod-usb-net-rtl8152"

# Modem
# Ethernet tethering
PACKAGES+=" kmod-mii kmod-usb-net kmod-usb-wdm kmod-usb-net-rndis \
kmod-usb-net-cdc-ether kmod-usb-net-cdc-ncm"

# FM350_gl
PACKAGES+=" atc-fib-fm350_gl xmm-modem kmod-mtk-t7xx"

# Qmodem
# PACKAGES+=" qmodem luci-app-qmodem -luci-app-qmodem-sms \
ndisc6 quectel-CM-5G-M sms-tool_q tom_modem"

# MHI Modem Host Interface
PACKAGES+=" kmod-mhi-bus kmod-mhi-net kmod-mhi-pci-generic kmod-mhi-wwan-ctrl kmod-mhi-wwan-mbim"

# Universal MBIM
PACKAGES+=" kmod-usb-net-cdc-mbim umbim luci-proto-mbim kmod-usb-serial-option picocom"
# QMI MBIM
# PACKAGES+=" kmod-usb-net-qmi-wwan uqmi luci-proto-qmi kmod-usb-serial-option picocom"

# dependencies
# USB/MBIM
PACKAGES+=" usbutils usb-modeswitch kmod-usb-uhci kmod-usb-ohci kmod-usb2 kmod-usb3 \
kmod-usb-acm kmod-usb-net-qmi-wwan"
PACKAGES+=" kmod-wwan comgt comgt-directip comgt-ncm modemmanager luci-proto-modemmanager modemmanager-rpcd dbus libqmi \
mbim-utils luci-proto-ncm dbus lua-cjson"

# Modem Management Tools
PACKAGES+=" modeminfo luci-app-modeminfo atinout modemband luci-app-modemband sms-tool luci-app-sms-tool-js picocom minicom"

# ModemInfo Serial Support
PACKAGES+=" kmod-usb-serial kmod-usb-serial-wwan kmod-usb-serial kmod-usb-serial-wwan \
modeminfo-serial-fibocom modeminfo-serial-xmm"

# Storage - NAS
PACKAGES+=" luci-app-diskman kmod-usb-storage kmod-usb-storage-uas ntfs-3g kmod-fs-ext4 kmod-fs-exfat"

# Monitoring
# PACKAGES+=" internet-detector internet-detector-mod-modem-restart luci-app-internet-detector vnstat2 vnstati2 luci-app-netmonitor"

# Themes
PACKAGES+=" luci-theme-argon"

# PHP8
PACKAGES+=" php8 php8-cgi php8-fastcgi php8-fpm php8-mod-ctype php8-mod-fileinfo php8-mod-iconv php8-mod-mbstring php8-mod-session php8-mod-zip"

# Extra
PACKAGES+=" luci-app-tinyfilemanager luci-app-cpu-status kmod-nls-utf8 kmod-macvlan kmod-tcp-bbr"

# Miscellaneous
MISC+=" zoneinfo-core zoneinfo-asia jq openssh-sftp-server \
screen lolcat luci-proto-atc luci-app-mmconfig \
luci-app-lite-watchdog luci-app-poweroffdevice luci-app-ramfree luci-app-ttyd luci-app-3ginfo-lite"

# VPN Tunnel
OPENCLASH3="coreutils-nohup bash dnsmasq-full iptables ca-certificates ipset ip-full iptables-mod-tproxy iptables-mod-extra libcap libcap-bin ruby ruby-yaml kmod-tun luci-app-openclash"
OPENCLASH4="coreutils-nohup bash dnsmasq-full ca-certificates ipset ip-full libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag kmod-nft-tproxy luci-app-openclash"
NIKKI="nikki luci-app-nikki"
NEKO="bash kmod-tun php8 php8-cgi luci-app-neko"
PASSWALL="chinadns-ng resolveip dns2socks dns2tcp ipt2socks microsocks tcping xray-core xray-plugin luci-app-passwall"

# Option Tunnel
add_tunnel_packages() {
    local option="$1"
    if [[ "$option" == "openclash" ]]; then
        PACKAGES+=" $OPENCLASH4"
    elif [[ "$option" == "openclash-nikki" ]]; then
        PACKAGES+=" $OPENCLASH4 $NIKKI"
    elif [[ "$option" == "openclash-nikki-passwall" ]]; then
        PACKAGES+=" $OPENCLASH4 $NIKKI $PASSWALL"
    elif [[ "$option" == "" ]]; then
        # No tunnel packages
        :
    fi
}

# Profil Name
configure_profile_packages() {
    local profile_name="$1"

    if [[ "$profile_name" == "rpi-4" ]]; then
        PACKAGES+=" kmod-i2c-bcm2835 i2c-tools kmod-i2c-core kmod-i2c-gpio"
    elif [[ "$profile_name" == "rpi-5" ]]; then
        PACKAGES+=" kmod-i2c-bcm2835 i2c-tools kmod-i2c-core kmod-i2c-gpio"
    elif [[ "${ARCH_2:-}" == "x86_64" ]]; then
        PACKAGES+=" kmod-iwlwifi iw-full pciutils wireless-tools"
    fi
}

# Packages Base Firmware Selector
configure_release_packages() {
    if [[ "${BASE:-}" == "openwrt" ]]; then
        MISC+=" luci-app-temp-status"
        EXCLUDED+=""
    elif [[ "${BASE:-}" == "immortalwrt" ]]; then
        MISC+=" wpad-openssl iw iwinfo wireless-regdb kmod-cfg80211 kmod-mac80211"
        EXCLUDED+=" -dnsmasq -cpusage -automount -libustream-openssl -default-settings-chn -luci-i18n-base-zh-cn"
        if [[ "${ARCH_2:-}" == "x86_64" ]]; then
            EXCLUDED+=" -kmod-usb-net-rtl8152-vendor"
        fi
    fi
}

# Build Firmware
build_firmware() {
    local target_profile="$1"
    local tunnel_option="${2:-}"
    local build_files="files"

    log "INFO" "Starting build for profile '$target_profile' with tunnel option '$tunnel_option'..."

    configure_profile_packages "$target_profile"
    add_tunnel_packages "$tunnel_option"
    configure_release_packages

    # Add Misc Packages
    PACKAGES+=" $MISC"

    make image PROFILE="$target_profile" PACKAGES="$PACKAGES $EXCLUDED" FILES="$build_files"
    local build_status=$?

    if [ "$build_status" -eq 0 ]; then
        log "SUCCESS" "Build completed successfully!"
    else
        log "ERROR" "Build failed with exit code $build_status"
        exit "$build_status"
    fi
}

# Validasi Argumen
if [ -z "${1:-}" ]; then
    log "ERROR" "Profile not specified. Usage: $0 <profile> [tunnel_option]"
    exit 1
fi

# Running Build
build_firmware "$1" "${2:-}"
