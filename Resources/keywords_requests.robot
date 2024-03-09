*** Settings ***
Library    OperatingSystem
Library    RequestsLibrary
Library    Collections
Library    json
Library    FakerLibrary

*** Keywords ***
Request_get
    [Arguments]    ${url}    ${log}=True
    ${response}=    GET    ${url}
    ${response_body}=    Set Variable    ${response.json()}
    ${response_json}=    Evaluate    json.dumps(${response_body}, indent=4)    json
    Run Keyword If    ${log}    Log To Console    ${response_json}
    RETURN    ${response}

Request_post
    [Arguments]    ${url}    ${body}=${None}    ${headers}=${None}    ${params}=${None}    ${log}=True
    Evaluate    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)    modules=urllib3
    ${session_name}    Create Session    alias=MySessionAlias    url=${url}    verify=False
    ${response}    POST On Session    MySessionAlias    url=    data=${body}    headers=${headers}    params=${params}

    Run Keyword If    ${log}
    ...    Log Response JSON    ${response}

    RETURN    ${response} 

Log Response JSON
    [Arguments]    ${response}
    ${response_body}=    Set Variable    ${response.json()}
    ${formatted_json}=    Evaluate    json.dumps($response_body, indent=4)    modules=json
    Log To Console    \n${formatted_json}

Process URL
    [Arguments]    ${url}    ${file_path}=../config/env.json
    ${final_url}=    Set Variable    ${url}

    # Verifica se a URL não começa com "http"
    ${protocol_not_http}=    Run Keyword And Return Status    Should Not Start With    ${url}    http

    IF    ${protocol_not_http}
        # Verifica se a URL contém uma barra "/"
        ${contains_slash}=    Run Keyword And Return Status    Should Contain    ${url}    /
        IF    ${contains_slash}
            ${parts}=    Evaluate    '${url}'.split('/')    json
            ${endpoint}=    Set Variable    ${parts}[0]
            ${path}=    Evaluate    '/'.join(${parts}[1:])    json
        ELSE
            ${endpoint}=    Set Variable    ${url}
            ${path}=    Set Variable    ${EMPTY}
        END

        # Lê o arquivo JSON e extrai o valor para o endpoint
        ${file_content}=    Get File    ${file_path}
        ${json_data}=    Evaluate    json.loads("""${file_content}""")    json
        ${env}=    Get From Dictionary    ${json_data}    env    ${None}
        ${env_data}=    Get From Dictionary    ${json_data}    ${env}    ${None}
        ${endpoint_value}=    Get From Dictionary    ${env_data}    ${endpoint}    ${None}

        # Usa o valor do endpoint do JSON se disponível, senão mantém o original
        ${final_endpoint}=    Set Variable If    '${endpoint_value}' != '${None}'    ${endpoint_value}    ${endpoint}

        # Concatena o endpoint e o caminho, adicionando a barra apenas se houver um caminho
        ${final_url}=    Set Variable If    '${path}' != '${EMPTY}'    ${final_endpoint}/${path}    ${final_endpoint}
    END

    RETURN    ${final_url}


JSON_CHANGE
    [Documentation]    Modifies a JSON file by changing or adding a value at a specified path. ex: ../jsons/get.json   body    {"name", "value"}
    [Arguments]    ${json}    ${path}    ${value}
    ${file_content}=    Get File    ${json}.json
    ${json_data}=    Evaluate    json.loads("""${file_content}""")    json
    ${body}=    Evaluate    ${value}    json
    Set To Dictionary    ${json_data}    ${path}    ${body}
    RETURN    ${json_data}

GET_VARIABLE_GLOBAL
    [Arguments]    ${variable}
    ${value_found}=    Get Variable Value    ${${variable}}
    RETURN    ${value_found[0]}
