"""Stand-in for your Day 2 code: a small simulated LTE lab.

On the real lab VM, replace the bodies of these functions with your Day 2 code
(subprocess, paramiko, requests, tshark). Keep the function names and the
AttachResult fields and nothing else in this lab needs to change.

Fault injection for the 'Break it' exercise (set before running robot):
    LAB_FAULT=no_ip     attach works but no IP is allocated
    LAB_FAULT=slow      attach takes longer than any normal timeout
    LAB_FAULT=core_down the core never answers
"""
import os
import time
from dataclasses import dataclass
from typing import Optional

UE_KEY = "00112233445566778899aabbccddeeff"   # the key stored on the UE SIM
EMM_UNKNOWN_IMSI = 8
EMM_MAC_FAILURE = 20


@dataclass
class AttachResult:
    imsi: str
    status: str                      # ATTACHED, REJECTED or TIMEOUT
    cause: Optional[int] = None      # EMM cause when rejected
    ip: str = ""
    setup_ms: int = 0

    @property
    def success(self):
        return self.status == "ATTACHED"

    @property
    def reject_cause(self):
        return self.cause


_state = {"core": False, "enb": False, "subs": {}, "attached": {}, "log": [], "next_ip": 2}


def _log(line):
    _state["log"].append(f"{time.strftime('%H:%M:%S')} {line}")


def start_core():
    _state["core"] = True
    _log("[core] MME, HSS, S-GW, P-GW started")


def start_enb(config="enb.conf"):
    _state["enb"] = True
    _log(f"[enb] eNodeB started with {config}")
    return {"name": "enb", "config": config}


def stop_all():
    _state.update(core=False, enb=False)
    _state["attached"].clear()
    _log("[core] all elements stopped")


def reset_ue_state():
    _state["attached"].clear()
    _log("[ue] state reset")


def provision_subscriber(imsi, key, opc):
    _state["subs"][imsi] = {"key": key, "opc": opc}
    _log(f"[hss] subscriber {imsi} provisioned")
    return {"imsi": imsi, "key": key, "opc": opc}


def attach(imsi, timeout=30.0):
    fault = os.environ.get("LAB_FAULT", "")
    _log(f"[ue] attach start imsi={imsi} timeout={timeout}s")
    if fault == "core_down" or not (_state["core"] and _state["enb"]):
        _log("[mme] no response")
        return AttachResult(imsi, "TIMEOUT", setup_ms=int(timeout * 1000))
    if fault == "slow":
        _log("[mme] attach too slow")
        return AttachResult(imsi, "TIMEOUT", setup_ms=int(timeout * 1000))
    sub = _state["subs"].get(imsi)
    if sub is None:
        _log(f"[mme] Attach Reject imsi={imsi} emm_cause={EMM_UNKNOWN_IMSI}")
        return AttachResult(imsi, "REJECTED", EMM_UNKNOWN_IMSI, setup_ms=250)
    if sub["key"] != UE_KEY:
        _log(f"[mme] Attach Reject imsi={imsi} emm_cause={EMM_MAC_FAILURE}")
        return AttachResult(imsi, "REJECTED", EMM_MAC_FAILURE, setup_ms=320)
    ip = ""
    if fault != "no_ip":
        ip = f"172.16.0.{_state['next_ip']}"
        _state["next_ip"] += 1
    _state["attached"][imsi] = ip
    _log(f"[mme] Attach Complete imsi={imsi} ip={ip or 'none'}")
    return AttachResult(imsi, "ATTACHED", ip=ip, setup_ms=240)


def detach(imsi):
    _state["attached"].pop(imsi, None)
    _log(f"[ue] detach imsi={imsi}")


def bearer_exists(imsi):
    return imsi in _state["attached"]


def measure_throughput(direction="DL", duration=5):
    base = {"DL": 42.5, "UL": 18.2}[direction.upper()]
    _log(f"[iperf3] {direction} {duration}s -> {base} Mbit/s")
    return base


def tail(n=40):
    return "\n".join(_state["log"][-int(n):])


def save_logs(path):
    with open(path, "w") as f:
        f.write("\n".join(_state["log"]) + "\n")
