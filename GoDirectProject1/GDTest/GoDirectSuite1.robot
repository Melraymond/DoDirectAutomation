*** Variables ***
${InformationList}    ${null}
${USB_GDX-TMP}    GDX-TMP 0F1024D5
${USB_GDX-FOR}    GDX-FOR 072002M1
${BLE_GDX_TMP}    GDX-TMP 0F106831
${BLE_GDX_FOR}    GDX-FOR 071004J9 
${port_1_gdx_tmp}    1
${port_2_gdx_for}    2
${port_5_no_sensor}    5
${port_negative_value}    -1
${grab_return}    99
${low_range}    18
${high_range}    30
${PICKLIST_SENSOR_1}    1
${CH_1}    1
${TEMPERATURE}       Temperature 
${FORCE}    Force
${Unit°C}    °C
${UNIT_N}    N

*** Settings ***  
Library    Process                      
Library    gdx 
Library    usbportfeed 
Library    keyfeeder        
                                                   
# Suite Setup    Log    I am inside Test Suite Setup
# Suite Teardown    Log    I am inside Test suite Teardown
# Test Setup    Log    I am inside Test Setup
# Test Teardown    Log    I am inside Test Teardown 
  
Default Tags    Baseline

*** Keywords ***

check_usb_temp_probe_KW
    [Documentation]    Fails keyword if specific Temperature Probe not on correct USB Port
    ${InformationList}    device info  
    Should Contain    ${InformationList}    ${USB_GDX-TMP}
  
check_usb_force_sensor_KW
    [Documentation]    Fails keyword if specific Force sensor not on correct USB Port
    ${InformationList}    device info  
    Should Contain    ${InformationList}    ${USB_GDX-FOR}
  
check_ble_temp_probe_KW
    [Documentation]    Fails keyword if specific blutooth Temperature Probe not found
    ${InformationList}    device info  
    Should Contain    ${InformationList}    ${BLE_GDX_TMP}
    
check_ble_force_sensor_KW
    [Documentation]    Fails keyword if specific blutooth Force Sensor not found
    ${InformationList}    device info  
    Should Contain    ${InformationList}    ${BLE_GDX_FOR}
    
Should Be X Than Y
    [Documentation]    Checking values within a set range gives reasonable knowledge
    ...    we PASS the test. Anything above or below this range will fail. This keyword
    ...    was tested with hot water and ice and would fail this Test when outside range.
    ...    Range can be adjusted via variables for low_range and high_range which are 
    ...    currently set to ${low_range} and ${high_range} variables
    [Arguments]    ${expression}
    Run Keyword If     
    ...    not(${expression})    
    ...    Fail    Number does not match Expression pattern.

recycle_open_ble
    keyfeeder.Send Some Keys    ${PICKLIST_SENSOR_1}
    Open Ble
    ${InformationList}    device info    
    Should Not Be Equal As Strings    ${InformationList}[0]    ${None}
 
*** Test Cases ***

usb_smoke_test_1_GDX_TMP
    [Tags]    usb_smoke
    Log    Smoke test verifies we can connect a USB GDX-TMP sensor
    usbportfeed.Choose Usb    ${port_1_gdx_tmp}
    open usb
    check_usb_temp_probe_KW 
    close  
  
usb_smoke_test_2_GDX_FOR
    [Tags]    usb_smoke
    Log    Smoke test verifies we can connect a USB GDX-FOR sensor
    usbportfeed.Choose Usb    ${port_2_gdx_for}
    open usb
    check_usb_force_sensor_KW 
    close

usb_select_invalid_port_GDX_TMP
    [Tags]    usb_negative_test 
    Log    Verify attempt to select usb port with no sensor on it
    usbportfeed.Choose Usb    ${port_5_no_sensor}
    open usb
    ${InformationList}    device info
    Should Be Equal As Strings    ${InformationList}    ${None}
    close    

usb_select_bad_input_port_GDX_TMP
    [Tags]    usb_negative_test
    Log    Verify attempt to select usb port using a -1 as input
    usbportfeed.Choose Usb    ${port_negative_value}
    open usb
    ${InformationList}    device info
    Should Be Equal As Strings    ${InformationList}    ${None}
    close

ble_smoke_test_1_GDX_TMP
    [Tags]    ble__smoke
    Log    Verify attempt to connect to a ble GDX-TMP Sensor
    Open Ble    ${BLE_GDX_TMP}
    check_ble_temp_probe_KW
    close
#    Sleep    3
    
ble_sensor_info_GDX_TMP
    [Tags]    ble_functional
    Log    Verify Sensor Info of a GDX-TMP probe can be gathered
    Open Ble    ${BLE_GDX_TMP}
    check_ble_temp_probe_KW
    ${InformationList}    Sensor Info
    ${flat}    Evaluate    [item for sublist in ${InformationList} for item in (sublist if isinstance(sublist, list) else [sublist])]
    ${result}=    Convert To Integer    ${CH_1}    
    Should Contain    ${flat}    ${result}
    Should Contain    ${flat}    ${Unit°C}   
    Should Contain    ${flat}    ${TEMPERATURE}
    close
#    Sleep    3
    
ble_sensor_start_with_no_device_GDX_TMP
    [Tags]    ble_functional
    Log    Verify proper return condition from start function if no device was selected
    ${grab_return}    Start    2
    Should Be Equal As Strings    ${grab_return}    ${None}
#    Sleep    3

ble_sensor_data_collection_GDX_TMP
    [Tags]    ble_functional
    Log    Verify we can collect a short 2 samples per second run with gdx-temp
    Open Ble    ${BLE_GDX_TMP}
    start    2000    
    ${InformationList}    read 
    Run Keyword and Continue on Failure    Should Be X Than Y   ${low_range} < ${InformationList[0]} < ${high_range}      
    stop
    close
    Sleep    3

ble_smoke_test_2_GDX_FOR
    [Tags]    ble_smoke
    Log    Verify attempt to connect to a ble GDX-FOR Sensor
    Open BLe   ${BLE_GDX_FOR}    bg=True
    check_ble_force_sensor_KW
    close
#    Sleep    3
 
 # yellow_sensor
    # Open Ble    ${YELLOW}
    # ${InformationList}    device info  
    # Should Contain    ${InformationList}    ${YELLOW}
    # close

ble_sensor_info_GDX_FOR
    [Tags]    ble_functional
    Log    Verify Sensor Info of a GDX-FOR sensor can be gathered
    Open Ble    ${BLE_GDX_FOR}
    check_ble_force_sensor_KW
    ${InformationList}    Sensor Info
    ${flat}    Evaluate    [item for sublist in ${InformationList} for item in (sublist if isinstance(sublist, list) else [sublist])]
    ${result}    Convert To Integer    ${CH_1}
    Should Contain    ${flat}    ${result}
    Should Contain    ${flat}    ${FORCE}   
    Should Contain    ${flat}    ${UNIT_N}
    close
#    Sleep    3


 ble_get_a_sensor_list
    [Tags]    ble_functional
    Log    Verify users can get a list of available sensors and pick the first one
#    ${result} =	Wait Until Keyword Succeeds	10x	1s	recycle_open_ble
    keyfeeder.Send Some Keys    ${PICKLIST_SENSOR_1}
    Open Ble   
    ${InformationList}    device info    
    Log    ${InformationList}[0]
    Should Not Be Equal As Strings    ${InformationList}[0]    ${None}
    close

       