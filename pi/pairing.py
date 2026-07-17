import os
import uuid
import threading
import serial
import requests
from config import BACKEND_URL, PAIRING_ID_FILE, API_KEY_FILE, UART_PORT, UART_BAUD, NFC_LINK_PREFIX
from indicators import red_led, green_led
from nfc_tag import connect_pn532, write_url_to_tag


def get_or_create_pairing_id():
    if os.path.exists(PAIRING_ID_FILE):
        with open(PAIRING_ID_FILE, "r") as f:
            return f.read().strip()
    new_id = str(uuid.uuid4())
    with open(PAIRING_ID_FILE, "w") as f:
        f.write(new_id)
    return new_id


def pair_device(pairing_id, wallet_token):
    response = requests.post(f"{BACKEND_URL}/devices/pair/qr",
                            json={"pairingId": pairing_id, "walletToken": wallet_token}, timeout=10)
    response.raise_for_status()
    return response.json()


def _cancelable_qr_wait(stop_event):
    with serial.Serial(UART_PORT, UART_BAUD, timeout=1) as ser:
        wallet_token = ""
        while not wallet_token and not stop_event.is_set():
            line = ser.readline()
            wallet_token = line.decode("utf-8", errors="ignore").strip()
        return wallet_token if not stop_event.is_set() else None


def _cancelable_nfc_wait(pairing_id, stop_event, poll_interval=3):
    while not stop_event.is_set():
        try:
            response = requests.get(f"{BACKEND_URL}/devices/pair/status",
                                    params={"pairingId": pairing_id},
                                    timeout=10,
                                    )
            response.raise_for_status()
            data = response.json()
            if data.get("paired") and "apiKey" in data:
                return data["apiKey"]
        except requests.exceptions.RequestException as e:
            print(f"[!] Status Check Failed, retrying: {e}")
        stop_event.wait(poll_interval)
    return None


def _claim_result(lock, result, stop_event, method, api_key):
    with lock:
        if stop_event.is_set():
            return False
        result["method"] = method
        result["apiKey"] = api_key
        stop_event.set()
        return True


def _qr_worker(pairing_id, result, stop_event, lock):
    try:
        wallet_token = _cancelable_qr_wait(stop_event)
        if not wallet_token:
            return
        print("[+] QR Scanned, attempting to pair...")
        response = pair_device(pairing_id, wallet_token)
        _claim_result(lock, result, stop_event, "qr", response["apiKey"])
    except Exception as e:
        if not stop_event.is_set():
            print(f"[!] QR pairing attempt failed: {e}")


def _nfc_worker(pairing_id, result, stop_event, lock):
    api_key = _cancelable_nfc_wait(pairing_id, stop_event)
    if api_key:
        _claim_result(lock, result, stop_event, "nfc", api_key)


def run_dual_pairing_flow():
    is_first_setup = not os.path.exists(PAIRING_ID_FILE)
    pairing_id = get_or_create_pairing_id()
    print(f"[+] Using pairingId: {pairing_id}")

    if is_first_setup:
        print("[+] First-time setup detected - writing pairing link to the NFC tag...")
        print("[+] Hold the tag near the antenna now...")
        try:
            pn532 = connect_pn532()
            pair_url = f"{NFC_LINK_PREFIX}{pairing_id}&mode=pair"
            write_url_to_tag(pn532, pair_url)
            print("[+] Tag written successfully.")
        except Exception as e:
            print(f"[!] Failed to write the initial pairing tag: {e}")
            print("[!] Aborting - there is no working tag to wait on.")
            return False

    print("[+] Waiting for either a QR scan or an NFC tap to pair this device...")
    red_led.blink(on_time=0.5, off_time=0.5)

    result = {}
    stop_event = threading.Event()
    lock = threading.Lock()
    qr_thread = threading.Thread(target=_qr_worker, args=(pairing_id, result, stop_event, lock))
    nfc_thread = threading.Thread(target=_nfc_worker, args=(pairing_id, result, stop_event, lock))
    qr_thread.start()
    nfc_thread.start()
    qr_thread.join()
    nfc_thread.join()

    red_led.off()
    if "apiKey" not in result:
        print("[!] Pairing failed on both QR and NFC")
        red_led.blink(on_time=0.1, off_time=0.1)
        return False

    print(f"[+] Paired successfully via {result['method'].upper()}")
    with open(API_KEY_FILE, "w") as f:
        f.write(result["apiKey"])

    print("[+] Rewriting tag for claim mode...")
    try:
        pn532 = connect_pn532()
        claim_url = f"{NFC_LINK_PREFIX}{pairing_id}&mode=claim"
        write_url_to_tag(pn532, claim_url)
    except Exception as e:
        print(f"[!] Warning: failed to rewrite tag to claim mode: {e}")
        print("[!] Pairing Succeeded, but the tag still says mode=pair.")

    green_led.on()
    print("[+] Paired Successfully - apiKey saved locally.")
    return True
