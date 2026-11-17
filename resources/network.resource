*** Settings ***
Documentation     Start, stop and reset the lab network. Used as suite and test hooks.
Library           LteLib

*** Keywords ***
Start Network
    [Documentation]    Start the core and the eNodeB.
    Start Core Network
    Start eNodeB    ${ENB_CONFIG}

Stop Network
    [Documentation]    Stop everything. Runs as suite teardown, even after failures.
    Stop Network Elements

Reset UE State
    [Documentation]    Cheap reset before every test.
    Clear UE State

Collect Artefacts
    [Documentation]    Copy the lab log into the results folder. Runs even when a test fails.
    Save Artefacts    ${OUTPUT DIR}/artefacts
