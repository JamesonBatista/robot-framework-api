*** Settings ***
Library    ../config/readJson.py
Library    OperatingSystem
Library    json
Library    Collections
Resource    keywords_requests.robot
Resource    key_validations.robot
Library    RequestsLibrary
Library    BuiltIn
Library    String

*** Keywords ***
Request
    [Arguments]    ${json}    ${log}=False
    ${json_data}=    Run Keyword If    '${json.__class__.__name__}' == 'str'    Load JSON Data    ${json}.json    ELSE    Set Variable    ${json}
    
    ${url_endpoint}=    Process URL    ${json_data["url"]}
    
    ${path_string}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${json_data}    path
    IF    ${path_string}
    ${variable_name}=    Set Variable    ${json_data["path"]}
    ${value_found}=    Get Variable Value    ${${variable_name}}

    ${url_endpoint}=    Set Variable    ${url_endpoint}/${value_found[0]}
    END

    Log To Console    \n\n 🔰 request in: ${url_endpoint}\n

    ${path_replace}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${json_data}    replace
    ${data}    Set Variable    False
    IF    ${path_replace}
    
        ${path_value_replace}    Set Variable    ${json_data['replace']}
        ${itens}    Split String    ${path_value_replace}    ,
        FOR    ${replace_val}    IN    @{itens}
            ${trim_value}    Strip String    ${replace_val}
            @{value_found}    Get Variable Value    ${${trim_value}}

            ${value_found}=    Evaluate    $value_found[0] if isinstance($value_found, list) and len($value_found) > 0 else $value_found
            
            ${is_list}=    Evaluate    isinstance($value_found, list)

            ${value_found}=    Set Variable If    ${is_list} and len($value_found) > 0    ${value_found[0]}    ${value_found}
           
            IF    not ${data}
                ${json_replace}    Replace    ${json_data}    ${trim_value}    ${value_found} 
                ${data}    Set Variable    True
            ELSE
                ${converter_json}    Evaluate    json.loads("""${json_replace}""")    json
                
                ${json_replace}    Replace    ${converter_json}    ${trim_value}    ${value_found}
            END    
        END
        ${json_data}    Set Variable    ${json_replace}
        ${json_data}    Evaluate    json.loads("""${json_data}""")    json
    END
    

    ${body}=    Get From Dictionary    ${json_data}    body    ${None}
    ${headers}=    Get From Dictionary    ${json_data}    headers    ${None}
    ${params}=    Get From Dictionary    ${json_data}    params    ${None}
    ${method}=    Get From Dictionary    ${json_data}    method    ${None}

    
    ${name_file_get}=    Run Keyword And Return Status    Should Contain    ${json}    get    ignore_case=${True}
    ${name_file_post}=    Run Keyword And Return Status    Should Contain    ${json}    post    ignore_case=${True}

    Run Keyword If    
    ...    ${log}    
    ...    Parse_JSON    ${json_data}
    
    ${response}=    Run Keyword If    ${name_file_get}
    ...    Request_get    ${url_endpoint}    ${log}
    ...    ELSE IF    ${name_file_post}
    ...    Request_post    ${url_endpoint}    ${body}    ${headers}    ${params}    ${log}
    ...    ELSE IF    '${method}' == 'GET'    
    ...    Request_get    ${url_endpoint}    ${log}
    ...    ELSE IF    '${method}' == 'POST'
    ...    Request_post    ${url_endpoint}    ${body}    ${headers}    ${params}    ${log}
    
    ${has_status}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${json_data}    status
    IF    ${has_status}
        ${variable_name}=    Set Variable    ${json_data["status"]}
        Should Be Equal As Numbers    ${response.status_code}    ${variable_name}
        Log To Console    \n ✅ [̳ EXPECT ]̳ status equal ${response.status_code}\n

    END

    ${has_expect}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${json_data}    expect
    Run Keyword If    ${has_expect}    Validate Expectations    ${response}    ${json_data['expect']}
    ${has_save}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${json_data}    save
    IF    ${has_save}
        FOR    ${item}    IN    @{json_data['save']}
            ${results}=    find_in_json    ${response.json()}    ${item['path']}
            ${val}    Set Variable If    ${item.get('as', ${None})}    ${item.get('as', ${None})}    ${item['path']}
            Run Keyword If    len(${results}) > 0    Save    ${val}    ${results}
            
        END
    END

    RETURN    ${response}
Load JSON Data
    [Arguments]    ${json_file_path}
    ${json_content}=    Get File    ${json_file_path}
    ${json_data}=    Evaluate    json.loads("""${json_content}""")    json
    RETURN    ${json_data}
Save
    [Arguments]    ${path}    ${values}=${None}    ${as}=${None}
    ${val}    Set Variable If    '${as}' != '${None}'    ${as}    ${path}

    ${is_list}=    Evaluate    isinstance($values, list)
    ${value_found}=    Set Variable If    ${is_list} and len($values) > 0    ${values[0]}    ${values}
    ${continuo_list}=    Evaluate    isinstance($value_found, list)
    IF    ${continuo_list}
        ${value_found}    Set Variable    ${value_found[0]}
    END

    Set Global Variable     @{${val}}    ${value_found}
    Log To Console    \n 🔵 SAVED value for path: [ ${val} ] and value: ${value_found} \n

STATUS_CODE
    [Arguments]    ${response}    ${path}=status    ${value}=200   
    Run Keyword If    '${path}' == 'status' or '${path}' == 'status_code'    Should Be Equal As Numbers    ${response.status_code}    ${value}
    Log To Console    \n ✅ [̳ EXPECT ]̳ ${path} equal ${response.status_code}\n

Replace
    [Arguments]    ${json}    ${string}    ${replace_with}

    ${json_type}=    Evaluate    $json.__class__.__name__
    ${replaced}=    Run Keyword If    '${json_type}' == 'str'
    ...    Transfor_DATA    ${json}.json    ${string}    ${replace_with}
    ...    ELSE    Converter JSON str    ${json}    ${string}    ${replace_with}
    RETURN    ${replaced}

Replace In String
    [Arguments]    ${json_str}    ${string}    ${replace_with}
    ${replaced}=    Replace String    ${json_str}    ${string}    ${replace_with}
    RETURN    ${replaced}

Transfor_DATA
    [Arguments]    ${data}    ${key}    ${new_value}
    ${json}=    Get File    ${data}
    # ${json_data}=    Evaluate    json.loads("""${json}""")    json
    ${replaced}    Replace In String    ${json}    ${key}    ${new_value}
    RETURN    ${replaced}

Converter JSON str
    [Arguments]    ${json}    ${key}    ${new_value}
    ${json_data}=    Evaluate    json.dumps($json)    json
    ${replaced}    Replace In String    ${json_data}    ${key}    ${new_value}
    RETURN    ${replaced}

Parse_JSON
    [Arguments]    ${json}
    Remove From Dictionary    ${json}    replace
    ${val}    Set Variable    ${json}
    ${json_data}=    Evaluate    json.dumps(${val}, indent=4)    json
    Log To Console    Payload: ${json_data}