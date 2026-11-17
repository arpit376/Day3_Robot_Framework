"""LteLib: the Robot keyword library built on the Day 2 code (Lab 3.4).

Keywords (the target interface from slide 29):
    Provision Subscriber, Start eNodeB, Attach UE, Get Attach Result,
    Measure Throughput
plus the housekeeping keywords used by the resource files.

Design rules (slide 31): one job per keyword, return data, every wait has a
timeout, explain failures.
"""
import os
from robot.api import logger
from robot.api.deco import keyword, library
from robot.utils import timestr_to_secs

import day2_lte as lab


@library(scope="SUITE", auto_keywords=False)
class LteLib:
    def __init__(self):
        self._last = {}          # imsi -> AttachResult

    # ---- housekeeping ----------------------------------------------------
    @keyword("Start Core Network")
    def start_core_network(self):
        """Start the core elements (MME, HSS, S-GW, P-GW)."""
        lab.start_core()

    @keyword("Start eNodeB")
    def start_enodeb(self, config="enb.conf"):
        """Start the eNodeB with ``config`` and return a process handle."""
        return lab.start_enb(config)

    @keyword("Stop Network Elements")
    def stop_network_elements(self):
        """Stop everything that was started. Safe to call twice."""
        lab.stop_all()

    @keyword("Clear UE State")
    def clear_ue_state(self):
        """Forget attached UEs so the next test starts clean."""
        lab.reset_ue_state()
        self._last.clear()

    @keyword("Save Artefacts")
    def save_artefacts(self, folder):
        """Write the lab log to ``folder`` and add a link to the Robot log."""
        os.makedirs(folder, exist_ok=True)
        path = os.path.join(folder, "lab.log")
        lab.save_logs(path)
        logger.info(f'<a href="{path}">lab.log</a>', html=True)
        return path

    # ---- the five keywords of the target interface ------------------------
    @keyword("Provision Subscriber")
    def provision_subscriber(self, imsi, key, opc):
        """Create the subscriber in the HSS and return its record."""
        return lab.provision_subscriber(imsi, key, opc)

    @keyword("Attach UE")
    def attach_ue(self, imsi, timeout="30s", expect_failure=False):
        """Attach the UE and return an AttachResult.

        ``timeout`` accepts Robot time strings (``30s``, ``1 min``) or numbers.
        With ``expect_failure=True`` a rejected attach is returned, not raised.
        """
        seconds = float(timestr_to_secs(timeout))
        result = lab.attach(imsi, timeout=seconds)
        self._last[imsi] = result
        if not result.success and not _truthy(expect_failure):
            logger.error(f"cause={result.reject_cause} status={result.status}")
            logger.info(lab.tail(40))
            raise AssertionError(
                f"UE {imsi} did not attach: {result.status}, "
                f"cause={result.reject_cause}. See the lab.log artefact.")
        return result

    @keyword("Get Attach Result")
    def get_attach_result(self, imsi):
        """Return the last AttachResult (status, cause, setup_ms) of ``imsi``."""
        if imsi not in self._last:
            raise AssertionError(f"No attach was run for {imsi}")
        return self._last[imsi]

    @keyword("Measure Throughput")
    def measure_throughput(self, direction="DL", duration="5s"):
        """Run a throughput measurement and return Mbit/s as a float."""
        return float(lab.measure_throughput(direction, int(timestr_to_secs(duration))))

    # ---- extra checks ----------------------------------------------------
    @keyword("Bearer Should Not Exist")
    def bearer_should_not_exist(self, imsi):
        """Fail if a default bearer exists for ``imsi``."""
        if lab.bearer_exists(imsi):
            raise AssertionError(f"A bearer exists for {imsi} but none was expected")

    @keyword("Detach UE")
    def detach_ue(self, imsi):
        """Detach the UE."""
        lab.detach(imsi)


def _truthy(value):
    return str(value).lower() in ("true", "1", "yes")
