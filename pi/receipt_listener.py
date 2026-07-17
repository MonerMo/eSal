import socket
import threading
import os
import select
import requests
from config import BACKEND_URL , API_KEY_FILE , USB_GADGET_DEVICE
from state import set_latest_receipt_id


def get_api_key():
    with open(API_KEY_FILE , "r") as f:
        return f.read().strip()

def send_receipt(raw_bytes : bytes):
    api_key = get_api_key()
    raw_text = raw_bytes.decode("latin-1")
    try:
        response = requests.post(
                f"{BACKEND_URL}/receipts",
                json={"rawData": raw_text},
                headers={"x-api-key" : api_key},
                timeout=10,
                )
        response.raise_for_status()
        receipt = response.json()
        set_latest_receipt_id(receipt["id"])
        print(f"[+] Receipt sent , status {response.status_code}")
    except Exception as e:
        print(f"[!] Failed to send receipt: {e}")

def start_tcp_listener():
    server = socket.socket(socket.AF_INET , socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR , 1)
    server.bind(("0.0.0.0" , 9100))
    server.listen(1)
    print("[+] Listening on TCP Port 9100...")


    while True:
        conn, addr = server.accept()
        print(f"[+] Connection from {addr}")
        data = b""
        with conn:
            while True:
                chunk = conn.recv(4096)
                if not chunk:
                    break
                data+=chunk
        if data:
            send_receipt(data)

def start_usb_listener(idle_timeout=3.0):
    print(f"[+] Opening {USB_GADGET_DEVICE} for  reading...")
    fd = os.open(USB_GADGET_DEVICE , os.O_RDONLY | os.O_NONBLOCK)
    print("[+] Listening On USB Gadget mode...")
    buffer = b""
    while True:
        ready, _,_ = select.select([fd] , [], [], idle_timeout)
        if ready:
            try:
                chuck = os.read(fd , 4096)
            except OSError as e:
                print(f"[!] USB read error: {e}")
                continue
            if chuck:
                buffer += chuck
        else:
            if buffer:
                send_receipt(buffer)
                buffer = b""

def run_listeners():

    from claim_scanner import start_claim_scanner
    tcp_thread = threading.Thread(target=start_tcp_listener , daemon=True)
    tcp_thread.start()

    claim_thread = threading.Thread(target=start_claim_scanner , daemon=True)
    claim_thread.start()

    usb_thread = threading.Thread(target=start_usb_listener , daemon=True)
    usb_thread.start()
    tcp_thread.join()
