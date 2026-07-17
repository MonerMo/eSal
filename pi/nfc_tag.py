import board
import busio
from digitalio import DigitalInOut
from adafruit_pn532.i2c import PN532_I2C

RESET_PIN = board.D6
REQ_PIN = board.D12


def connect_pn532():
    i2c = busio.I2C(board.SCL, board.SDA)
    reset_pin = DigitalInOut(RESET_PIN)
    req_pin = DigitalInOut(REQ_PIN)
    pn532 = PN532_I2C(i2c, debug=False, reset=reset_pin, req=req_pin)
    ic, ver, rev, support = pn532.firmware_version
    print(f"[+] Found PN532 firmware {ver}.{rev}")
    pn532.SAM_configuration()
    return pn532


def build_ndef_uri_message(url: str) -> bytes:
    prefixes = {
        "http://www.": 0x01,
        "https://www.": 0x02,
        "http://": 0x03,
        "https://": 0x04,
    }
    code = 0x00
    rest = url
    for prefix, abbrev_code in prefixes.items():
        if url.startswith(prefix):
            code = abbrev_code
            rest = url[len(prefix):]
            break

    payload = bytes([code]) + rest.encode("utf-8")
    record_type = b"U"
    header = 0xD1
    return bytes([header, len(record_type), len(payload)]) + record_type + payload


def build_type2_tlv(ndef_message: bytes) -> bytes:
    tlv = bytes([0x03, len(ndef_message)]) + ndef_message
    tlv += bytes([0xFE])
    return tlv


def write_tag(pn532, data: bytes, start_page: int = 4):
    remainder = len(data) % 4
    if remainder:
        data = data + bytes(4 - remainder)

    page_count = len(data) // 4
    for i in range(page_count):
        page = start_page + i
        block = data[i * 4:(i + 1) * 4]
        if not pn532.ntag2xx_write_block(page, block):
            raise RuntimeError(f"Failed writing page {page}")
    print(f"[+] Wrote {page_count} pages starting at page {start_page}")


def write_url_to_tag(pn532, url: str, detect_timeout: float = 5.0):
    """Waits for a tag to be in range, then writes `url` to it as an NDEF URI record."""
    uid = None
    elapsed = 0.0
    while uid is None:
        uid = pn532.read_passive_target(timeout=0.5)
        elapsed += 0.5
        if elapsed >= detect_timeout:
            raise RuntimeError("No tag detected within timeout")

    tlv_data = build_type2_tlv(build_ndef_uri_message(url))
    write_tag(pn532, tlv_data)
