import serial
import requests
from config import BACKEND_URL , UART_PORT , UART_BAUD
from state import get_latest_receipt_id
from receipt_listener import get_api_key


def claim_receipt(wallet_token: str):
    print(f"[Debug] raw wallet_token {wallet_token!r} (len={len(wallet_token)})")
    receipt_id = get_latest_receipt_id()
    if not receipt_id:
        print("[!] No receipt to claim yet , ignoring scan")
        return

    api_key = get_api_key()
    try:
        response = requests.post(
                f"{BACKEND_URL}/receipts/{receipt_id}/claim/qr",
                json={"walletToken" : wallet_token} ,
                headers={"x-api-key": api_key},
                timeout=10,
                )
        response.raise_for_status()
        print(f"[+] Receipt {receipt_id} claimed successfully")
    except requests.exceptions.HTTPError as e:
        try:
            detail = e.response.json().get("message" , e.response.text)
        except ValueError:
            detail = e.response.text
        print(f"[!] Failed to claim receipt: {detail}")
    except Exception as e:
        print(f"[!] Failed to claim receipt : {e}")

def start_claim_scanner():
    print("[+] Claim Scanner Ready - waiting for customer QR Scans")
    with serial.Serial(UART_PORT , UART_BAUD, timeout=1) as ser:
        while True:
            line = ser.readline()
            if not line:
                continue
            wallet_token = line.decode("utf-8" , errors="ignore").strip()
            if wallet_token:
                claim_receipt(wallet_token)
