"""Variable file for lab test bed 02.
Robot loads every UPPER_CASE name here as a variable (for example ${ENB_HOST}).
A different test bed = a different file, not different tests (Day 3, slide 12)."""

# Hosts and API
ENB_HOST = "10.0.1.12"
CORE_HOST = "10.0.1.10"
API_URL = "http://127.0.0.1:8099"       # the local mock provisioning API
SSH_USER = "lab"
KEY_FILE = "~/.ssh/id_rsa"

# Test subscriber (matches the Day 2 sample log)
IMSI = "001010123456101"
KEY = "00112233445566778899aabbccddeeff"
OPC = "63bfa50ee6523365ff14c1f45f88737d"
WRONG_KEY = "ffffffffffffffffffffffffffffffff"
UNKNOWN_IMSI = "001010999999999"

# Expected results
EXPECTED_STATUS = "ATTACHED"
EMM_CAUSE_UNKNOWN_IMSI = 8          # IMSI unknown in the HSS
DL_MIN_MBPS = 35.0                  # KPI threshold, lives in data, not in the test
ENB_CONFIG = "enb.conf"
