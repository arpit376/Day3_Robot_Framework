*** Settings ***
Documentation     Tests for the LteLib keyword library (Lab 3.4, slide 29 interface).
Library           LteLib
Resource          ../resources/network.resource
Resource          ../resources/kpi.resource
Variables         ../env/lab01.py
Suite Setup       Start Network
Suite Teardown    Stop Network
Test Setup        Reset UE State
Test Teardown     Collect Artefacts

*** Test Cases ***
Provision Subscriber Returns The Record
    [Tags]    smoke    library
    ${record}=    Provision Subscriber    ${IMSI}    ${KEY}    ${OPC}
    Should Be Equal    ${record}[imsi]    ${IMSI}

Attach UE And Get Attach Result
    [Tags]    smoke    library
    Provision Subscriber    ${IMSI}    ${KEY}    ${OPC}
    Attach UE    ${IMSI}
    ${result}=    Get Attach Result    ${IMSI}
    Should Be Equal    ${result.status}    ATTACHED
    Should Be True    ${result.setup_ms} > 0

Timeout Accepts Robot Time Strings
    [Documentation]    30s, 1 min and plain numbers all work.
    [Tags]    library
    Provision Subscriber    ${IMSI}    ${KEY}    ${OPC}
    Attach UE    ${IMSI}    timeout=1 min
    Attach UE    ${IMSI}    timeout=45

Failed Attach Explains Itself
    [Documentation]    The message names the IMSI, the status and the cause.
    [Tags]    library    negative
    Run Keyword And Expect Error    UE ${UNKNOWN_IMSI} did not attach: REJECTED, cause=8*
    ...    Attach UE    ${UNKNOWN_IMSI}

Downlink Throughput Meets The Threshold
    [Tags]    kpi    library
    ${mbps}=    Throughput Should Meet Threshold    DL
    Log    Measured ${mbps} Mbit/s    console=True
