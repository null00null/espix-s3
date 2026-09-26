import serial
import time
import sys

def main():
    port = 'COM3'
    baud = 115200
    timeout = 15
    if len(sys.argv) > 1:
        timeout = float(sys.argv[1])

    ser = serial.Serial(port, baud, timeout=0.1)
    print(f"Monitoring {port} at {baud} for {timeout}s...")

    # Hardware reset via RTS
    ser.setDTR(False)
    ser.setRTS(True)
    time.sleep(0.1)
    ser.setRTS(False)

    start = time.time()
    while time.time() - start < timeout:
        data = ser.read(1024)
        if data:
            sys.stdout.buffer.write(data)
            sys.stdout.buffer.flush()
    ser.close()

if __name__ == '__main__':
    main()
