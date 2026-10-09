*** Settings ***
Documentation     Page object for the Sauce Demo login page (the start page).
...
...               Tests talk to the page only through these keywords; the locators stay here,
...               so a UI change means one edit in this file, not in every test.
Resource          ../common.resource
# The login lands on the product list, so this page needs its "should be open" check.
Resource          InventoryPage.resource


*** Variables ***
# data-test attributes are made for automation, so they are the most stable locators.
${USERNAME_INPUT}         css:[data-test="username"]
${PASSWORD_INPUT}         css:[data-test="password"]
${LOGIN_BUTTON}           css:[data-test="login-button"]
${LOGIN_ERROR_MESSAGE}    css:[data-test="error"]


*** Keywords ***
Open Login Page
    [Documentation]    Loads the login page again in the browser that is already open.
    ...                The data-driven login tests run several attempts in one browser.
    Go To    ${UI_URL}

Login Page Should Be Open
    [Documentation]    Waits for the login form and checks the page title.
    Wait Until Element Is Visible    ${LOGIN_BUTTON}
    Title Should Be    Swag Labs

Submit Login Form
    [Documentation]    Types ${username} and ${password} and clicks "Login".
    ...
    ...                Does not check the result on purpose: positive tests follow it with
    ...                ``Products Page Should Be Open``, negative tests with
    ...                ``Login Error Message Should Be``.
    [Arguments]    ${username}    ${password}
    Login Page Should Be Open
    Input Text        ${USERNAME_INPUT}    ${username}
    # Input Password keeps the value out of log.html.
    Input Password    ${PASSWORD_INPUT}    ${password}
    Click Button      ${LOGIN_BUTTON}

Login Error Message Should Be
    [Documentation]    Checks the red error message shown under the login form.
    [Arguments]    ${expected_message}
    Wait Until Element Is Visible    ${LOGIN_ERROR_MESSAGE}
    Element Text Should Be    ${LOGIN_ERROR_MESSAGE}    ${expected_message}

Open Browser And Log In
    [Documentation]    Test setup for every test that starts on the product list:
    ...                opens a new browser, logs in as ${username} and waits for the products.
    [Arguments]    ${username}=${STANDARD_USER}
    Open Browser On Login Page
    Submit Login Form    ${username}    ${PASSWORD}
    Products Page Should Be Open
