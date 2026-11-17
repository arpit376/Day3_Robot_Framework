"""Lab 3.4 starter: build your own Robot keyword library.

1. Copy this file:   cp exercises/MyLteLib_starter.py libraries/MyLteLib.py
2. Replace every TODO. The Day 2 functions are in day2_lte.py (start_core, attach, ...).
3. Run:              robot -A lab.args exercises/my_library_test.robot
Compare with libraries/LteLib.py only when you are stuck.

Rules to follow (slide 31): one job per keyword, return data, every wait has a
timeout, log context before raising.
"""
from robot.api import logger
from robot.api.deco import keyword, library
from robot.utils import timestr_to_secs

import day2_lte as lab


@library(scope="SUITE", auto_keywords=False)
class MyLteLib:

    @keyword("Start Core Network")
    def start_core_network(self):
        """TODO: start the core with lab.start_core()."""
        raise NotImplementedError("TODO")

    @keyword("Start eNodeB")
    def start_enodeb(self, config="enb.conf"):
        """TODO: start the eNodeB and return the handle."""
        raise NotImplementedError("TODO")

    @keyword("Stop Network Elements")
    def stop_network_elements(self):
        """TODO: stop everything."""
        raise NotImplementedError("TODO")

    @keyword("Provision Subscriber")
    def provision_subscriber(self, imsi, key, opc):
        """TODO: provision the subscriber and return the record."""
        raise NotImplementedError("TODO")

    @keyword("Attach UE")
    def attach_ue(self, imsi, timeout="30s"):
        """TODO: 1) convert timeout with timestr_to_secs  2) call lab.attach
        3) on failure: logger.error the cause, logger.info(lab.tail(40)) and
        raise AssertionError naming the IMSI  4) return the AttachResult."""
        raise NotImplementedError("TODO")
