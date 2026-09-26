import serial
import threading
import sys
import os

PORT = 'COM3'
BAUD = 115200

def read_loop(ser):
    while True:
        try:
            data = ser.read(ser.in_waiting or 1)
            if data:
                sys.stdout.write(data.decode('utf-8', errors='replace'))
                sys.stdout.flush()
        except Exception:
            break

def main():
    print(f"Connecting to ESP32-S3 Linux on {PORT} at {BAUD} baud...")
    print("Press Ctrl+C to exit.\n")
    try:
        ser = serial.Serial(PORT, BAUD, timeout=0.1)
    except Exception as e:
        print(f"Failed to open {PORT}: {e}")
        return

    t = threading.Thread(target=read_loop, args=(ser,), daemon=True)
    t.start()

    # Send a newline to trigger prompt
    ser.write(b"\n")

    try:
        while True:
            line = input()
            ser.write((line + "\n").encode('utf-8'))
    except KeyboardInterrupt:
        print("\nExiting terminal session.")
    finally:
        ser.close()

if __name__ == '__main__':
    main()
