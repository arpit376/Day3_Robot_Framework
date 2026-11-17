*** Settings ***
Documentation     Provision a subscriber over REST with RequestsLibrary (slide 23).
...               The suite starts a small local API (tools/mock_api.py) for you.
Library           RequestsLibrary
Library           Process
Variables         ../../env/lab01.py
Suite Setup       Start Mock Api
Suite Teardown    Stop Mock Api

*** Test Cases ***
Provisioning A Subscriber Returns Created
    [Tags]    api    smoke
    &{sub}=    Create Dictionary    imsi=${IMSI}    key=${KEY}
    Provision Subscriber Via API    ${sub}

API Rejects A Subscriber Without An IMSI
    [Tags]    api    negative
    &{sub}=    Create Dictionary    key=${KEY}
    ${resp}=    POST On Session    prov    /subscribers    json=${sub}    expected_status=400
    Should Be Equal As Integers    ${resp.status_code}    400
    Should Contain    ${resp.text}    imsi required

*** Keywords ***
Provision Subscriber Via API
    [Arguments]    ${sub}
    [Documentation]    POST the subscriber and check the HTTP status.
    ${resp}=    POST On Session    prov    /subscribers    json=${sub}
    Should Be True    ${resp.ok}
    Should Be Equal As Integers    ${resp.status_code}    201

Start Mock Api
    ${py}=    Evaluate    sys.executable    modules=sys
    Start Process    ${py}    ${CURDIR}/../../tools/mock_api.py    alias=api
    Create Session    prov    ${API_URL}    max_retries=0
    Wait Until Keyword Succeeds    10x    0.5s    GET On Session    prov    /health

Stop Mock Api
    Terminate All Processes    kill=True
