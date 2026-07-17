import time
import os
DEVICE = "/dev/g_printer0"
print(f"[+] Opening {DEVICE} for reading...")
fd = os.open(DEVICE, os.O_RDONLY)
print("[+] waiting for data")
while True:
    chunk = os.read(fd , 4096)
    if chunk:
        print(f"[+] Read{len(chunk)} bytes at {time.time():.3f}: {chunk[:60]!r}")
    else:
        print(f"[!] got empty read at {time.time():.3f}")
