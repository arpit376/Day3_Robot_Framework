*** Settings ***
Documentation     KPI keywords. Thresholds come from the variable file, not from the tests.
Library           LteLib

*** Keywords ***
Throughput Should Meet Threshold
    [Arguments]    ${direction}=DL    ${duration}=5s
    [Documentation]    Measure throughput and compare it with DL_MIN_MBPS. Returns the value.
    ${mbps}=    Measure Throughput    ${direction}    ${duration}
    Should Be True    ${mbps} >= ${DL_MIN_MBPS}
    ...    msg=${direction} throughput ${mbps} Mbit/s is below the threshold ${DL_MIN_MBPS} Mbit/s.
    RETURN    ${mbps}
