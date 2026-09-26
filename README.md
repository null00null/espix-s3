# 🐧 Espix-S3: Linux 6.11 (NO-MMU) for ESP32-S3 N16R8

[![ESP32-S3](https://img.shields.io/badge/SoC-ESP32--S3%20N16R8-red.svg)](https://www.espressif.com)
[![Kernel](https://img.shields.io/badge/Linux%20Kernel-6.11%20NO--MMU-blue.svg)](https://kernel.org)
[![Architecture](https://img.shields.io/badge/Arch-Xtensa%20FDPIC-green.svg)](https://gcc.gnu.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Russian Docs](https://img.shields.io/badge/Docs-Русская%20версия-lightgrey.svg)](README_RU.md)

**Espix-S3** is a complete, bootable **Linux 6.11 (NO-MMU)** distribution customized specifically for the **ESP32-S3** microcontroller (revision **N16R8**: 16 MB Quad SPI Flash, 8 MB Octal PSRAM).

It runs dynamically-linked userland binaries with shared libraries via **Xtensa FDPIC ABI**, supports full **Wi-Fi networking (ESP-Hosted IPC)**, **SSH remote access**, **SD card storage**, **MicroPython 3**, **Nano**, and an embedded **HTTP server**.

---

## ⚡ Key Highlights

* **Architecture**: Dual-Core Tensilica Xtensa LX7 @ 240 MHz (single-core Linux active).
* **FDPIC ABI**: Dynamic linking without MMU using Function Descriptors.
* **XIP Flash Execution**: Linux kernel executes in-place (`0x42120000`) directly from SPI Flash to maximize available RAM.
* **RAM Allocation**: ~7.3 MB of the 8 MB Octal PSRAM is dedicated to user processes and SLAB cache.
* **Wi-Fi & Networking**: Full hardware Wi-Fi stack managed by ESP-IDF co-processor over Shared Memory Ringbuffer IPC (`espsta0` interface, WPA2, DHCP, Ping, Wget).
* **Remote Access**: Dropbear SSH daemon and interactive serial UART console (`115200` baud).
* **Persistent `/etc`**: Writable JFFS2 flash partition keeps your SSH keys, Wi-Fi passwords, and user settings across reboots.

---

## 📦 Releases

| Edition | Description | Recommended For |
|---|---|---|
| **v1.0 (Base)** | Minimal footprint, Linux 6.11, Wi-Fi, SSH, UART, ~5.5 MB free RAM. | Lightweight headless IoT, micro-routers, benchmarks. |
| **v2.0 (Dev & Storage)** | Includes **MicroPython 1.22**, **Nano 8.1**, **BusyBox HTTPD** (port 8080), **SD Card** (FAT32/EXT2/EXT3) auto-mount. | On-device scripting, hacking, web dashboards, persistent logging. |

> 📥 Download ready-to-flash binary packages from the [Releases](../../releases) tab!

---

## 🚀 Quick Start (Flashing)

### 1. Requirements
* ESP32-S3 board with **16 MB Flash** & **8 MB Octal PSRAM** (e.g. ESP32-S3-DevKitC-1 N16R8, YD-ESP32-S3, etc.).
* Python 3 with `esptool`:
  ```bash
  pip install esptool pyserial
  ```

### 2. Flash in 1 Step

Extract your chosen release archive (`v1.0` or `v2.0`), open a terminal in that folder, and run:

**On Windows:**
```cmd
scripts\flash.bat COM3
```

**On Linux / macOS:**
```bash
chmod +x scripts/flash.sh
./scripts/flash.sh /dev/ttyUSB0
```

*Flash memory layout:*
* `0x00000000` — `bootloader.bin`
* `0x00008000` — `partition-table.bin`
* `0x00010000` — `network_adapter.bin` (ESP-Hosted IPC)
* `0x000b0000` — `etc.jffs2` (Writable configuration)
* `0x00120000` — `xipImage` (Linux 6.11 Kernel XIP)
* `0x00600000` — `rootfs.cramfs` (Compressed Root Filesystem)

---

## 🔑 Login & Console

Connect your serial terminal at **115200 baud** (8N1):
```bash
python tools/terminal.py COM3
```

```text
Espix-S3 (buildroot) login: root
Password: (empty, press Enter)
```

To set a password permanently:
```bash
passwd
```

---

## 🌐 Wi-Fi & SSH Setup

1. Bring up interface:
   ```bash
   ip link set espsta0 up
   ```
2. Scan networks:
   ```bash
   iw dev espsta0 scan | grep SSID
   ```
3. Connect to Wi-Fi:
   ```bash
   wpa_passphrase "YourSSID" "YourPassword" > /etc/wpa_supplicant.conf
   wpa_supplicant -B -i espsta0 -c /etc/wpa_supplicant.conf
   udhcpc -i espsta0
   ```
4. Access via SSH from your PC:
   ```bash
   ssh root@<ESP32_IP_ADDRESS>
   ```

---

## 💾 SD Card Pinout (v2.0)

In v2.0, SD Card support is configured via SPI bit-bang to avoid conflicts with display peripherals:

| SD Module Pin | ESP32-S3 GPIO | Function |
|---|---|---|
| **MISO / DO** | `GPIO 35` | SPI MISO |
| **SCK / CLK** | `GPIO 36` | SPI Clock |
| **MOSI / DI** | `GPIO 37` | SPI MOSI |
| **CS** | `GPIO 38` | Chip Select |
| **VCC** | `3.3V` | Power |
| **GND** | `GND` | Ground |

* When inserted, the SD card is auto-mounted at `/mnt/sd`.
* Any executable inside `/mnt/sd/bin` is added to `$PATH`.
* If `/mnt/sd/packages.sh` exists, it executes automatically on boot.

---

## 🕸️ Built-in Web Server (v2.0)

BusyBox `httpd` is automatically launched on **port 8080**.
Point your browser to:
```text
http://<ESP32_IP>:8080/
```
Included features:
* Real-time hardware status page (`/cgi-bin/status.sh`).
* Host static HTML/JS from `/var/www` or `/mnt/sd/www`.

---

## 🛠️ Build From Source

Build configurations are provided in `configs/`:
* `configs/devkit_c1_8m_linux.config` — Linux kernel defconfig with MMC, FAT32, EXT2, and SPI_GPIO.
* `configs/esp32s3-devkit-c1.dts` — Device Tree Source.
* `configs/busybox.config` — BusyBox applet configuration.

---

## 📜 License

Distributed under the [MIT License](LICENSE).
Linux kernel and components retain their respective upstream GPL-2.0 / LGPL licenses.
