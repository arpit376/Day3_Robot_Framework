*** Settings ***
Documentation     Reusable LTE procedures built from library keywords (slides 13 and 25).
Library           LteLib

*** Keywords ***
Provision Default Subscriber
    [Documentation]    Provision the test subscriber from the variable file.
    Provision Subscriber    ${IMSI}    ${KEY}    ${OPC}

Attach And Verify IP
    [Arguments]    ${imsi}    ${timeout}=30s
    [Documentation]    Attach the UE, check an IP was allocated and return the AttachResult.
    ${result}=    Attach UE    ${imsi}    ${timeout}
    Should Be Equal    ${result.status}    ${EXPECTED_STATUS}
    Should Not Be Empty    ${result.ip}    msg=UE ${imsi} attached but got no IP address. Check the P-GW and the default bearer.
    RETURN    ${result}
