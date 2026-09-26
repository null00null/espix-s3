@echo off
setlocal
echo ========================================================
echo   Espix-S3 Flasher for Windows (ESP32-S3 N16R8)
echo ========================================================

set PORT=%1
if "%PORT%"=="" set PORT=COM3

echo Using port: %PORT% (pass another port as argument if needed, e.g. flash.bat COM5)
echo.

python -m esptool --port %PORT% --chip esp32s3 -b 921600 write_flash ^
  0x00000000 bootloader.bin ^
  0x00008000 partition-table.bin ^
  0x00010000 network_adapter.bin ^
  0x000b0000 etc.jffs2 ^
  0x00120000 xipImage ^
  0x00600000 rootfs.cramfs

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo   Flashing SUCCESS! Open terminal at 115200 baud.
    echo   Login: root (no password)
    echo ========================================================
) else (
    echo.
    echo [ERROR] Flashing failed! Check COM port and connection.
)

pause
