*** Settings ***
Documentation     Page object for the Sauce Demo login page.
...               Tests talk to the page only through these keywords; the locators stay here,
...               so a UI change means one edit in this file, not in every test.
Resource          ../common.resource
Resource          InventoryPage.resource


*** Variables ***
# data-test attributes are made for automation, so they are the most stable locators.
${LOGIN_USERNAME}     css:[data-test="username"]
${LOGIN_PASSWORD}     css:[data-test="password"]
${LOGIN_BUTTON}       css:[data-test="login-button"]
${LOGIN_ERROR}        css:[data-test="error"]


*** Keywords ***
Open Login Page
    [Documentation]    Loads the login page again in the current browser
    ...                (data-driven tests run several logins in one browser).
    Go To    ${UI_URL}

Login Page Should Be Open
    [Documentation]    Checks that the login form is shown.
    Wait Until Element Is Visible    ${LOGIN_BUTTON}
    Title Should Be    Swag Labs

Login As
    [Documentation]    Fills in the form and submits it. Does not check the result,
    ...                so negative tests can reuse it.
    [Arguments]    ${username}    ${password}
    Login Page Should Be Open
    Input Text        ${LOGIN_USERNAME}    ${username}
    # Input Password keeps the value out of log.html.
    Input Password    ${LOGIN_PASSWORD}    ${password}
    Click Button      ${LOGIN_BUTTON}

Login Error Should Be
    [Documentation]    Checks the red error message under the login form.
    [Arguments]    ${expected}
    Wait Until Element Is Visible    ${LOGIN_ERROR}
    Element Text Should Be    ${LOGIN_ERROR}    ${expected}

Open Shop And Log In
    [Documentation]    Suite/test setup for every test that starts on the products page.
    [Arguments]    ${username}=${STANDARD_USER}
    Open Shop
    Login As    ${username}    ${PASSWORD}
    Products Page Should Be Open
