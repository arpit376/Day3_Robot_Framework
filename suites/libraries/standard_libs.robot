*** Settings ***
Documentation     A tour of the standard libraries on LTE data (slide 21).
Library           OperatingSystem
Library           Process
Library           String
Library           Collections

*** Variables ***
${LOG_FILE}       ${CURDIR}/../../data/sample_mme.log

*** Test Cases ***
OperatingSystem: Sample Log Exists And Is Not Empty
    [Tags]    libraries
    File Should Exist    ${LOG_FILE}
    File Should Not Be Empty    ${LOG_FILE}

String: Find The Reject Lines In The MME Log
    [Tags]    libraries
    ${text}=    Get File    ${LOG_FILE}
    ${rejects}=    Get Lines Matching Regexp    ${text}    .*Attach Reject.*
    Should Contain    ${rejects}    emm_cause=8
    ${count}=    Get Line Count    ${rejects}
    Should Be Equal As Integers    ${count}    1

Collections: Collect The IMSIs That Attached
    [Tags]    libraries
    ${text}=    Get File    ${LOG_FILE}
    ${lines}=    Get Lines Matching Regexp    ${text}    .*Attach Complete.*
    @{imsis}=    Create List
    FOR    ${line}    IN    @{lines.splitlines()}
        ${imsi}=    Get Regexp Matches    ${line}    imsi=(\\d{15})    1
        Append To List    ${imsis}    ${imsi}[0]
    END
    Length Should Be    ${imsis}    2
    List Should Contain Value    ${imsis}    001010123456001

Process: Start And Stop A Local Program
    [Documentation]    Stands in for starting an eNodeB or UE binary.
    [Tags]    libraries
    ${py}=    Evaluate    sys.executable    modules=sys
    ${result}=    Run Process    ${py}    -c    print('core started')
    Should Be Equal As Integers    ${result.rc}    0
    Should Contain    ${result.stdout}    core started
