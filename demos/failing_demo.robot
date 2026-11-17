*** Settings ***
Documentation     FAILS ON PURPOSE (Lab 3.2 step 'Break it', slide 19).
...               Compare the two failure messages in log.html.
Library           LteLib
Resource          ../resources/network.resource
Variables         ../env/lab01.py
Suite Setup       Start Network
Suite Teardown    Stop Network
Test Teardown     Collect Artefacts

*** Test Cases ***
Weak Failure Message
    [Tags]    demo-fail
    ${result}=    Attach UE    ${UNKNOWN_IMSI}    expect_failure=True
    Should Be Equal    ${result.status}    ATTACHED

Actionable Failure Message
    [Tags]    demo-fail
    ${result}=    Attach UE    ${UNKNOWN_IMSI}    expect_failure=True
    Should Be Equal    ${result.status}    ATTACHED
    ...    msg=UE ${UNKNOWN_IMSI} was ${result.status} with EMM cause ${result.cause}. Next: check the HSS subscription.
    ...    values=False
