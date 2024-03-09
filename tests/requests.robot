*** Settings ***
Resource    ../Resources/resources_keywords.robot
Library    FakerLibrary    locale=pt_BR
*** Variables ***

*** Test Cases ***
Test init
    ${response}    Request    ../jsons/post_token

Test - Generate new users
    ${name}    FakerLibrary.Name
    Save    faker_name    ${name}
    ${email}    FakerLibrary.Email
    Save    faker_email    ${email}

    ${response}    Request    ../jsons/post_new_user    True



