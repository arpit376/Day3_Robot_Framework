*** Settings ***
Documentation     Attach, detach and reject basics (Lab 3.2).
Library           OperatingSystem
Library           LteLib
Resource          ../resources/network.resource
Resource          ../resources/procedures.resource
Variables         ../env/lab01.py
Suite Setup       Start Network
Suite Teardown    Stop Network
Test Setup        Reset UE State
Test Teardown     Collect Artefacts

*** Test Cases ***
UE Attaches And Gets An IP Address
    [Documentation]    Attach one UE, check IP allocation.
    [Tags]    smoke    attach    REQ-ATTACH-01
    Provision Subscriber    ${IMSI}    ${KEY}    ${OPC}
    ${result}=    Attach UE    ${IMSI}
    Should Be Equal    ${result.status}    ATTACHED
    Should Not Be Empty    ${result.ip}

UE Detaches Cleanly
    [Documentation]    After detach no bearer must remain.
    [Tags]    smoke    attach    REQ-ATTACH-02
    Provision Default Subscriber
    Attach And Verify IP    ${IMSI}
    Detach UE    ${IMSI}
    Bearer Should Not Exist    ${IMSI}

Unknown IMSI Is Rejected With The Expected Cause
    [Documentation]    A subscriber that is not provisioned must get EMM cause 8.
    [Tags]    functional    negative    REQ-ATTACH-03
    ${result}=    Attach UE    ${UNKNOWN_IMSI}    expect_failure=True
    Should Be Equal    ${result.status}    REJECTED
    Should Be Equal As Integers    ${result.cause}    ${EMM_CAUSE_UNKNOWN_IMSI}
    Bearer Should Not Exist    ${UNKNOWN_IMSI}

Attach Setup Time Is Reasonable
    [Documentation]    Setup time of a single attach stays below one second.
    [Tags]    kpi    REQ-ATTACH-04
    Provision Default Subscriber
    ${result}=    Attach UE    ${IMSI}
    Should Be True    ${result.setup_ms} < 1000
    ...    msg=Attach took ${result.setup_ms} ms, expected below 1000 ms.
