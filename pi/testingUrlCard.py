import board
import busio
from digitalio import DigitalInOut
from adafruit_pn532.i2c import PN532_I2C

# ---- change this to any link you want on the tag ----
URL = "https://youtu.be/dQw4w9WgXcQ"   # a classic test video :)

# NFC Forum URI prefix codes: the first payload byte replaces the scheme
URI_PREFIXES = {
    "https://www.": 0x02,
    "http://www.":  0x01,
    "https://":     0x04,
    "http://":      0x03,
}

def build_ndef_uri(url):
    """Return the exact bytes that go into user memory (TLV + NDEF URI record)."""
    prefix_code, rest = 0x00, url
    for prefix, code in URI_PREFIXES.items():
        if url.startswith(prefix):
            prefix_code, rest = code, url[len(prefix):]
            break
    payload = bytes([prefix_code]) + rest.encode("ascii")

    record = bytes([
        0xD1,           # header: MB=1 ME=1 SR=1, TNF=0x01 (well-known type)
        0x01,           # type length = 1
        len(payload),   # payload length
        0x55,           # type = 'U' (URI record)
    ]) + payload

    assert len(record) < 255, "URL too long for short TLV format"
    tlv = bytes([0x03, len(record)]) + record + bytes([0xFE])

    if len(tlv) % 4:                      # pad to full 4-byte pages
        tlv += bytes(4 - (len(tlv) % 4))
    return tlv

def read_pages(pn, start, count):
    out = b""
    for p in range(start, start + count):
        try:
            block = pn.ntag2xx_read_block(p)
        except TypeError:
            return None
        if block is None:
            return None
        out += bytes(block)
    return out

i2c = busio.I2C(board.SCL, board.SDA)
reset_pin = DigitalInOut(board.D6)
req_pin = DigitalInOut(board.D12)
pn532 = PN532_I2C(i2c, debug=False, reset=reset_pin, req=req_pin)

try:
    ic, ver, rev, support = pn532.firmware_version
    print(f"[+] Found pn532 firmware {ver}.{rev}")
except RuntimeError as e:
    print(f"[!] could not talk to pn532 over i2c : {e}")
    raise SystemExit(1)

pn532.SAM_configuration()

data = build_ndef_uri(URL)
n_pages = len(data) // 4
print(f"[+] NDEF message: {len(data)} bytes -> pages 4..{3 + n_pages}")
print("[+] Place the NTAG215 flat on the antenna and hold still...")

while True:
    uid = pn532.read_passive_target(timeout=0.5)
    if uid is None:
        continue
    if len(uid) != 7:
        print(f"[!] {len(uid)}-byte UID - not an NTAG, skipping")
        continue

    print(f"[+] Tag detected - UID: {''.join(f'{b:02X}' for b in uid)}")

    ok = True
    for i in range(n_pages):
        if not pn532.ntag2xx_write_block(4 + i, data[i*4:(i+1)*4]):
            print(f"[!] Write failed at page {4 + i} - keep it flat, retrying...")
            ok = False
            break
    if not ok:
        continue

    if read_pages(pn532, 4, n_pages) == data:
        print(f"[+] Verified! Tag now holds: {URL}")
        print("[+] Tap the TOP edge of your iPhone against it")
        break
    print("[!] Verify mismatch - tag probably moved, tap again")
