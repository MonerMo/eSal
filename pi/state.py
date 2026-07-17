import threading
_lock = threading.Lock()
_latest_receipt_id = None

def set_latest_receipt_id(receipt_id):
    global _latest_receipt_id
    with _lock:
        _latest_receipt_id = receipt_id

def get_latest_receipt_id():
    with _lock:
        return _latest_receipt_id
