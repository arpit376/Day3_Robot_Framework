*** Settings ***
Documentation     Checks your own library (copy MyLteLib_starter.py to libraries/MyLteLib.py first).
Library           MyLteLib
Variables         ../env/lab01.py
Suite Setup       Run Keywords    Start Core Network    AND    Start eNodeB
Suite Teardown    Stop Network Elements

*** Test Cases ***
Subscriber Can Be Provisioned
    ${record}=    Provision Subscriber    ${IMSI}    ${KEY}    ${OPC}
    Should Be Equal    ${record}[imsi]    ${IMSI}

My Attach UE Keyword Works
    Provision Subscriber    ${IMSI}    ${KEY}    ${OPC}
    ${result}=    Attach UE    ${IMSI}    timeout=30s
    Should Be Equal    ${result.status}    ATTACHED
    Should Not Be Empty    ${result.ip}

My Attach UE Keyword Explains A Failure
    Run Keyword And Expect Error    *did not attach*    Attach UE    ${UNKNOWN_IMSI}
