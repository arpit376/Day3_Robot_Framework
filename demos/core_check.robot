*** Settings ***
Documentation     Check a remote element over SSH (slide 22).
...               Needs a reachable host with systemd and an SSH key. Not part of the default run.
...               Run:  robot -A lab.args --variable CORE_HOST:<host> --variable KEY_FILE:<key> demos/core_check.robot
Library           SSHLibrary
Variables         ../env/lab01.py

*** Test Cases ***
Core Service Is Active
    [Tags]    ssh
    Open Connection    ${CORE_HOST}
    Login With Public Key    ${SSH_USER}    ${KEY_FILE}
    ${out}=    Execute Command    systemctl is-active mme
    Should Be Equal    ${out}    active
    [Teardown]    Close All Connections
