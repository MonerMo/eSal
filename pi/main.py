import os
from config import API_KEY_FILE
from pairing import run_dual_pairing_flow
from receipt_listener import run_listeners

def main():
    if not os.path.exists(API_KEY_FILE):
        paired = run_dual_pairing_flow()
        if not paired:
            return
    run_listeners()
if __name__ == "__main__":
    main()
