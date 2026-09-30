# Wallbreaker 🛡️⚡

> Instant system-wide proxy switcher & network bypass toolkit for Linux desktop and terminal environments.

**Wallbreaker** is a lightweight bash & Python utility engineered to route Linux network traffic through live, verified HTTP/SOCKS proxies with a single on/off toggle. Built to quickly bypass restrictive local networks, captive portals, and campus firewalls on GNOME and terminal environments.

---

## ⚡ Features

- **One-Command Toggle:** Instantly switch between `on`, `off`, or `toggle` states.
- **GNOME Desktop System-Wide Integration:** Automatically configures desktop proxy settings (`gsettings`) for browsers like Firefox, Chrome, and system web views.
- **CLI / Terminal Sync:** Generates a shell environment file (`proxy_env.sh`) providing `http_proxy`, `https_proxy`, and `all_proxy` exports.
- **Built-in Live Scanner:** Automatically scans and tests proxy pools for HTTPS/SSL tunneling support (`CONNECT` handshake verification) to prevent dead-node hanging.
- **Zero Heavy Dependencies:** Runs purely using Bash, Python 3 standard library, and `curl`.

---

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/<your-username>/wallbreaker.git
cd wallbreaker
chmod +x wallbreaker.sh
```

### 2. Usage

#### Enable Proxy (Auto-picks a responsive verified proxy)
```bash
./wallbreaker.sh on
```

#### Enable a Specific Proxy
```bash
./wallbreaker.sh on http://13.217.196.158:1001
```

#### Disable Proxy
```bash
./wallbreaker.sh off
```

#### Toggle State
```bash
./wallbreaker.sh toggle
```

#### Check Current Status
```bash
./wallbreaker.sh status
```

#### Apply to Current Terminal Shell
```bash
source ./proxy_env.sh
```

---

## 🌐 System Configuration (Browser Setup)

To make sure your web browser respects Wallbreaker's system changes:

* **Firefox:** Go to `Settings` ➔ `Network Settings` ➔ Select **"Use system proxy settings"**.
* **Chromium / Chrome:** Automatically syncs with GNOME desktop settings.

---

## 📄 License
MIT License. Free for educational and authorized network testing use.
