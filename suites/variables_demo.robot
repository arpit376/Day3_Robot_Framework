*** Settings ***
Documentation     Variable scopes in action (slide 12). Run it and read the log.
Variables         ../env/lab01.py

*** Variables ***
${SUITE_VAR}      defined in the Variables section, visible in the whole suite

*** Test Cases ***
Global And Suite Variables Are Visible
    [Tags]    variables
    Log    Global/file value: ENB_HOST=${ENB_HOST}
    Log    Suite value: ${SUITE_VAR}
    Should Not Be Empty    ${ENB_HOST}

Test Variable Lives Inside One Test
    [Tags]    variables
    Set Test Variable    ${TEST_VAR}    only this test can see me
    Log    ${TEST_VAR}
    Variable Should Exist    ${TEST_VAR}

Test Variable Is Gone In The Next Test
    [Tags]    variables
    Variable Should Not Exist    ${TEST_VAR}

Local Variables Live Inside A Keyword
    [Tags]    variables
    ${doubled}=    Double It    21
    Should Be Equal As Integers    ${doubled}    42
    Variable Should Not Exist    ${local_value}

*** Keywords ***
Double It
    [Arguments]    ${number}
    [Documentation]    Arguments and return values are local to the keyword.
    ${local_value}=    Evaluate    ${number} * 2
    RETURN    ${local_value}
