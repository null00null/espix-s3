#!/usr/bin/env bash
set -e

PORT="${1:-/dev/ttyUSB0}"

echo "========================================================"
echo "  Espix-S3 Flasher for Linux / macOS (ESP32-S3 N16R8)"
echo "========================================================"
echo "Using port: $PORT (usage: ./flash.sh /dev/ttyACM0)"
echo ""

esptool.py --port "$PORT" --chip esp32s3 -b 921600 write_flash \
  0x00000000 bootloader.bin \
  0x00008000 partition-table.bin \
  0x00010000 network_adapter.bin \
  0x000b0000 etc.jffs2 \
  0x00120000 xipImage \
  0x00600000 rootfs.cramfs

echo ""
echo "========================================================"
echo "  Flashing SUCCESS! Open terminal at 115200 baud."
echo "  Login: root (no password)"
echo "========================================================"
