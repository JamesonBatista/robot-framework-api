*** Settings ***
Library    ../config/readJson.py
Library    OperatingSystem
Library    json
Library    Collections
Resource    keywords_requests.robot
Resource    resources_keywords.robot

*** Keywords ***

Validate Expectations
    [Arguments]    ${response}    ${expectations}
    ${response_body}=    Set Variable    ${response.json()}
    ${val}    Set Variable    '...'
    FOR    ${expect}    IN    @{expectations}
        ${values}=    Find In Json    ${response_body}    ${expect['path']}
        ${values}    Evaluate    $values[0] if isinstance($values, list) and len($values) == 1 else $values
     
        ${eq}=    Get From Dictionary    ${expect}    eq    ${None}
        ${as}=    Get From Dictionary    ${expect}    as    ${None}
        ${val}=    Set Variable If    '${as}' != '${None}'    ${expect['as']}    ${expect['path']} 
        Run Keyword If    '${eq}' == '${None}'
        ...    Log To Console    \n ▶️ Path found:[${expect['path']}] and value: ${values}\n 
        Handle Found Values    ${expect['path']}    ${values}    ${expect.get('eq', ${None})}    ${expect.get('save', ${None})}    ${val}
        
    END
Handle Found Values
    [Arguments]    ${path}    ${values}    ${expected_value}=${None}    ${expected_save}=${None}    ${as}=${None}
    ${value}    Set Variable If    '${as}' != '${None}'    ${as}    ${path}
    IF    isinstance($values, list) and len(${values}) == 0
        Fail    \n Value for path '${path}' was not found in the response.
    ELSE
        Log    \n🔵 Found values for '${path}': ${values}\n
        
        IF    '${expected_value}' != '${None}'
            ${match}=    Run Keyword And Return Status    Should Contain    ${values}    ${expected_value}
            
            IF    ${match}
                ${eq_val}    Set Variable    ${expected_value}

                Log To Console    \n ✅ [̳ EXPECT ]̳ ${path} contain or equal ${eq_val}\n
                IF    ${expected_save}
                    
                      
                    IF    not isinstance($values, list)
                        Run Keyword If    '${values}' == '${eq_val}'    Save    ${value}    ${values}
                    ELSE
                         FOR    ${val}    IN    @{values}
                        Run Keyword If    '${val}' == '${eq_val}'    Save    ${value}    ${val}
                        
                        END
                    END

                   
                END
            END

            IF    not ${match}
                Fail    \n ⛔️ The expected value '${expected_value}' for path '${path}' was not found in the values: ${values}\n
            END
        END
    END

Values Should Contain
    [Arguments]    ${values}    ${expected_value}
    ${is_contained}=    Run Keyword And Return Status    Should Contain    ${values}    ${expected_value}
    IF    not ${is_contained}
        Fail    \nThe expected value '${expected_value}' was not found in the values: ${values}\n
    END