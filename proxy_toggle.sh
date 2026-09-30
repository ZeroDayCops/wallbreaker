#!/usr/bin/env bash
# ==============================================================================
# System Proxy Toggle Script
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="${SCRIPT_DIR}/.current_proxy"
ENV_FILE="${SCRIPT_DIR}/proxy_env.sh"
WORKING_LIST="${SCRIPT_DIR}/working_proxies.txt"
PROXY_LIST="${SCRIPT_DIR}/free-proxy-list.txt"

# Default confirmed working HTTPS proxy
DEFAULT_PROXY="http://13.217.196.158:1001"

set_gnome_proxy() {
    local proto="$1"
    local host="$2"
    local port="$3"

    if command -v gsettings >/dev/null 2>&1; then
        if [ "$proto" = "socks4" ] || [ "$proto" = "socks5" ]; then
            gsettings set org.gnome.system.proxy.socks host "$host"
            gsettings set org.gnome.system.proxy.socks port "$port"
            gsettings set org.gnome.system.proxy.http host ""
            gsettings set org.gnome.system.proxy.http port 0
            gsettings set org.gnome.system.proxy.https host ""
            gsettings set org.gnome.system.proxy.https port 0
        else
            gsettings set org.gnome.system.proxy.http host "$host"
            gsettings set org.gnome.system.proxy.http port "$port"
            gsettings set org.gnome.system.proxy.https host "$host"
            gsettings set org.gnome.system.proxy.https port "$port"
            gsettings set org.gnome.system.proxy.socks host ""
            gsettings set org.gnome.system.proxy.socks port 0
        fi
        gsettings set org.gnome.system.proxy mode 'manual'
    fi
}

disable_gnome_proxy() {
    if command -v gsettings >/dev/null 2>&1; then
        gsettings set org.gnome.system.proxy mode 'none'
        gsettings set org.gnome.system.proxy.http host ""
        gsettings set org.gnome.system.proxy.http port 0
        gsettings set org.gnome.system.proxy.https host ""
        gsettings set org.gnome.system.proxy.https port 0
        gsettings set org.gnome.system.proxy.socks host ""
        gsettings set org.gnome.system.proxy.socks port 0
    fi
}

write_env_file() {
    local full_url="$1"
    cat <<ENVEOF > "$ENV_FILE"
export http_proxy="$full_url"
export https_proxy="$full_url"
export HTTP_PROXY="$full_url"
export HTTPS_PROXY="$full_url"
export all_proxy="$full_url"
export ALL_PROXY="$full_url"
export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
export NO_PROXY="localhost,127.0.0.1,localaddress,.localdomain.com"
ENVEOF
}

clear_env_file() {
    cat <<ENVEOF > "$ENV_FILE"
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY no_proxy NO_PROXY
ENVEOF
}

find_live_proxy() {
    python3 - << 'PYEOF'
import subprocess
from concurrent.futures import ThreadPoolExecutor
import sys

# Check working_proxies.txt first if present
targets = []
for fname in ["/home/b1t3x0p/Downloads/procxysystem/working_proxies.txt", "/home/b1t3x0p/Downloads/procxysystem/free-proxy-list.txt"]:
    try:
        with open(fname) as f:
            targets.extend([l.strip() for l in f if l.strip()])
    except Exception:
        pass

def check(p):
    try:
        res = subprocess.run(
            ["curl", "-s", "-m", "3", "--proxy", p, "https://cloudflare.com/cdn-cgi/trace"],
            capture_output=True,
            text=True
        )
        if res.returncode == 0 and "ip=" in res.stdout:
            return p
    except Exception:
        pass
    return None

with ThreadPoolExecutor(max_workers=30) as ex:
    for res in ex.map(check, targets[:150]):
        if res:
            print(res)
            sys.exit(0)

sys.exit(1)
PYEOF
}

enable_proxy() {
    local target_proxy="$1"

    if [ -z "$target_proxy" ]; then
        if [ -f "$STATE_FILE" ]; then
            target_proxy=$(cat "$STATE_FILE")
        fi
    fi

    if [ -z "$target_proxy" ]; then
        echo "[*] Searching for a verified HTTPS-capable proxy..."
        live=$(find_live_proxy)
        if [ $? -eq 0 ] && [ -n "$live" ]; then
            target_proxy="$live"
        else
            echo "[*] Using verified US proxy: $DEFAULT_PROXY"
            target_proxy="$DEFAULT_PROXY"
        fi
    fi

    local proto=$(echo "$target_proxy" | sed -e 's,^\(.*\)://.*,\1,g')
    local url_no_proto=$(echo "$target_proxy" | sed -e 's,^.*://,,g')
    local host=$(echo "$url_no_proto" | cut -d: -f1)
    local port=$(echo "$url_no_proto" | cut -d: -f2)

    echo "[*] Activating System Proxy -> ${proto}://${host}:${port}"
    set_gnome_proxy "$proto" "$host" "$port"
    write_env_file "$target_proxy"
    echo "$target_proxy" > "$STATE_FILE"

    echo "[+] System proxy is now ON."
    echo "[i] For active terminal shells: source ./proxy_env.sh"
}

disable_proxy() {
    echo "[*] Disabling system proxy..."
    disable_gnome_proxy
    clear_env_file
    rm -f "$STATE_FILE"
    echo "[-] System proxy is now OFF."
    echo "[i] For active terminal shells: source ./proxy_env.sh"
}

show_status() {
    echo "================ System Proxy Status ================"
    if command -v gsettings >/dev/null 2>&1; then
        local mode=$(gsettings get org.gnome.system.proxy mode)
        local h_host=$(gsettings get org.gnome.system.proxy.http host)
        local h_port=$(gsettings get org.gnome.system.proxy.http port)
        local s_host=$(gsettings get org.gnome.system.proxy.socks host)
        local s_port=$(gsettings get org.gnome.system.proxy.socks port)
        echo "GNOME Proxy Mode : $mode"
        echo "GNOME HTTP Host  : $h_host:$h_port"
        echo "GNOME SOCKS Host : $s_host:$s_port"
    fi

    if [ -f "$STATE_FILE" ]; then
        echo "Active Saved URL : $(cat "$STATE_FILE")"
    else
        echo "Active Saved URL : (None)"
    fi
    echo "====================================================="
}

case "$1" in
    on|enable)
        enable_proxy "$2"
        ;;
    off|disable)
        disable_proxy
        ;;
    status)
        show_status
        ;;
    scan|find)
        find_live_proxy
        ;;
    toggle)
        if command -v gsettings >/dev/null 2>&1; then
            current_mode=$(gsettings get org.gnome.system.proxy mode)
            if [ "$current_mode" = "'manual'" ]; then
                disable_proxy
            else
                enable_proxy "$2"
            fi
        fi
        ;;
    *)
        echo "Usage: $0 {on [proxy_url]|off|toggle|status|scan}"
        exit 1
        ;;
esac
