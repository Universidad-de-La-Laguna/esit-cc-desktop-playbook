#!/usr/bin/env python3
import socket
import time
import sys

LDAP_SERVER = "193.145.100.18"
LDAP_PORT = 389
TIMEOUT = 5

# LDAP BER minimal BindRequest (anonymous bind)
# Esto es un bind LDAPv3 vacío válido (muy básico)
BIND_REQ = bytes.fromhex(
    "30"  # LDAPMessage (SEQUENCE)
    "0c"  # length
    "02 01 01"  # messageID = 1
    "60 07"  # BindRequest
    "02 01 03"  # LDAPv3
    "04 00"  # empty bind DN
    "80 00"  # simple auth empty password
)

def main():
    print(f"[+] Connecting to {LDAP_SERVER}:{LDAP_PORT}")

    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(TIMEOUT)
        s.connect((LDAP_SERVER, LDAP_PORT))
        print("[OK] TCP connect")

        print("[+] Sending LDAP bind")
        s.send(BIND_REQ)

        print("[+] Waiting response...")
        data = s.recv(4096)

        if not data:
            print("[-] No data received (possible VLAN/firewall issue)")
            sys.exit(2)

        print(f"[OK] Received {len(data)} bytes")
        print(data.hex())

    except socket.timeout:
        print("[-] TIMEOUT (no LDAP response)")
        sys.exit(3)

    except Exception as e:
        print(f"[-] ERROR: {e}")
        sys.exit(1)

    finally:
        try:
            s.close()
        except:
            pass

if __name__ == "__main__":
    main()