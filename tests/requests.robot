*** Settings ***
Resource    ../Resources/resources_keywords.robot
Library    FakerLibrary    locale=pt_BR
*** Variables ***

*** Test Cases ***
Test - generate new token and save
    ${response}    Request    ../jsons/post_token

Test - Generate new users testing using replace function
    ${name}    FakerLibrary.Name
    Save    faker_name    ${name}
    ${email}    FakerLibrary.Email
    Save    faker_email    ${email}

    ${response}    Request    ../jsons/post_new_user


Test - Validation big return jsons
    ${response}    Request    ../jsons/get_json_validation

Test - Change jsons    
    ${json}=    JSON_CHANGE    ../jsons/get_changeJSON    status    200
    ${response}    Request    ${json}    True