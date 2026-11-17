"""Check that the lab can run:  python check_setup.py"""
import importlib
import sys

ok = True
print(f"Python {sys.version.split()[0]}")
if sys.version_info < (3, 8):
    print("  FAIL: Python 3.8 or newer is needed"); ok = False
for mod, pip in (("robot", "robotframework"), ("RequestsLibrary", "robotframework-requests"),
                 ("SSHLibrary", "robotframework-sshlibrary")):
    try:
        m = importlib.import_module(mod)
        print(f"  ok   {pip} {getattr(m, '__version__', '')}")
    except ImportError:
        print(f"  FAIL {pip} is missing:  pip install {pip}"); ok = False
try:
    import robot
    major = int(robot.__version__.split(".")[0])
    if major < 5:
        print("  FAIL: Robot Framework 5 or newer is needed (RETURN keyword)"); ok = False
except Exception:
    pass
print("READY" if ok else "NOT READY: fix the lines marked FAIL")
sys.exit(0 if ok else 1)
