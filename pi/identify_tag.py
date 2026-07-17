import board
import busio
from digitalio import DigitalInOut
from adafruit_pn532.i2c import PN532_I2C


i2c = busio.I2C(board.SCL , board.SDA)
reset_pin = DigitalInOut(board.D6)
req_pin = DigitalInOut(board.D12)

pn532 = PN532_I2C(i2c , debug=False , reset=reset_pin , req=req_pin)
try:
    ic , ver , rev ,support = pn532.firmware_version
    print(f"[+] Found pn532 firmware {ver}.{rev}")
except RuntimeError as e:
    print(f"[!] could not talk to pn532 over i2c : {e}")
    print("[!] check wiring and i2c enabled")
    raise SystemExit(1)

pn532.SAM_configuration()

print("[+] Place a card near the antenna (ctrl + c) to stop")
last_uid = None
while True:
    uid= pn532.read_passive_target(timeout=0.5)
    if uid is None:
        last_uid = None
        continue
    if uid == last_uid:
        continue
    last_uid = uid


    uid_hex= "".join(f"{b:02X}" for b in uid)
    print(f"[+] Tag Detected - UID: {uid_hex} ({len(uid)} bytes)")
    if len(uid) == 4:
        print(" -> Likey mifare classic")
    elif len(uid) == 7:
        print(" -> likely ntag")
    else:
        print("unrecognized")
